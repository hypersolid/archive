class Exclusive < ActiveRecord::Base
  include ItemConcerns
  include ThinkingSphinx::Scopes
  include ActiveModel::ForbiddenAttributesProtection

  acts_as_paranoid

  extend FriendlyId
  friendly_id :full_title, use: :slugged

  has_paper_trail only: [:maximum_quantity]

  attr_accessible :tag_list, :title, :price, :start_at, :end_at, :gift_card, :gift_card_kind
  attr_accessible :lead_time, :description, :designers_notes, :size_and_fit,
  :designer_id, :option_names, :options_attributes, :maximum_quantity,
  :minimum_quantity, :stage_message, :custom_stage_message, :stage_image,
  :qubit_category, :show_in_boutique, :category_ids, :meta_data_attributes,
  :delivery_and_returns, :quantity, :prev_quantity

  attr_accessor :quantity, :prev_quantity

  acts_as_ordered_taggable

  belongs_to :image
  belongs_to :rollover_image, class_name: 'Image'
  belongs_to :designer
  has_one :meta_data, as: :parent
  has_many :images, as: :parent
  has_many :shopping_bag_exclusives
  has_many :shopping_bags, through: :shopping_bag_exclusives, uniq: true

  has_many :categories_exclusives
  has_many :categories, through: :categories_exclusives

  has_many :shop_exclusives
  has_many :shops, through: :shop_exclusives
  has_many :options, class_name: 'ExclusiveOption'

  before_validation :set_price_for_gift_card
  validates :title, :start_at, :end_at, :lead_time, presence: true
  validates :price, presence: true
  validates :price, numericality: { greater_than: 0 },  unless: :gift_card?
  validates :price, numericality: { greater_than_or_equal_to: 0 }, if: :gift_card?

  validates :gift_card_kind, presence: true, inclusion: { in: [GiftCard::REGULAR, GiftCard::VIRTUAL] }, if: ->(t) { t.gift_card? }

  default_scope order('exclusives.start_at DESC')
  scope :current, -> {
    where('end_at > ? and start_at <= ? ', Time.zone.now, Time.zone.now).pending
  }
  scope :waiting, -> { pending.where('NOT(? between start_at and end_at)', Time.current) }
  scope :in_shop, -> { current.where(show_in_boutique: true) }
  scope :on_designer_page, -> { where(show_on_designer_page: true) }
  scope :to_feature, ->{ current.order(:end_at) }
  scope :closed, -> { where(status: 'closed') }
  scope :pending, -> { where(status: 'pending') }
  scope :closed_in, ->(span) {
    where('end_at between ? and ? ', Time.zone.now - span, Time.zone.now)
  }
  scope :open, where("status != ?", "closed")
  scope :for_designer, ->(designer_id) { where(designer_id: designer_id) }
  scope :by_title_or_designer, ->(*q) {
    q.first ?  includes(:designer).where("title like :q or designers.name like :q ", q: "%#{q.first}%") : scoped
  }
  scope :with_gift_cards, -> { where(gift_card: true) }
  scope :without_gift_cards, -> { where(gift_card: false) }

  accepts_nested_attributes_for :meta_data
  accepts_nested_attributes_for :options, allow_destroy: true,
    reject_if: proc { |attrs| attrs[:choices_as_string].blank? }

  before_save :set_breadcrumbs_category
  after_commit :update_price_in_bag!, on: :update

  def set_breadcrumbs_category
    result = []
    categories.each do |category|
      assumption = category.parents.map(&:name)
      if ['FOR HER', 'FOR HIM'].include?(assumption.first) && assumption.length > result.length
        result = assumption
      end
    end
    self.breadcrumbs_category = result.join(' > ')
  end

  def update_price_in_bag!
    shopping_bags.unpurchased.each do |basket|
      basket.shopping_bag_exclusives.for_exclusive(id).map(&:update_price!)
    end
  end

  def current_status
    case
    when closed?
      'inactive'
    when current?
      'active'
    when pending?
      'pending'
    end
  end

  def reorder_images(previous_positions, current_positions, item_id)
    @item = item_id
    @current_image = images.where(id: @item).first
    return if [@item, @current_image, previous_positions, current_positions].any?(&:blank?)

    @previous_position = (previous_positions || []).index(@item)
    @current_position = (current_positions || []).index(@item)

    if images.count == current_positions. size
      @current_image.insert_at(@current_position)
      touch
    else
      @steps = @current_position - @previous_position
      if @steps < 0
        @steps.abs.times { @current_image.move_higher }
        touch
      elsif @steps > 0
        @steps.times { @current_image.move_lower }
        touch
      end
    end
  end

  [GiftCard::REGULAR, GiftCard::VIRTUAL].each do |m|
    define_method "gift_card_is_#{m}?" do
      gift_card? && gift_card_kind.to_s == m
    end
  end

  def set_price_for_gift_card
    self.price ||= 0 if gift_card?
  end

  def delivery_and_returns
    super.presence || I18n.t('delivery_and_returns')
  end

  def options_to_hash
    Hash[
         *self.option_names.split(',')
           .map(&:split).flatten
           .zip(self.options.map(&:choices).transpose).flatten(1)
        ]
  rescue
    {}
  end

  def duplicate
    new_object = self.dup
    new_object.meta_data = self.meta_data.try(:dup)
    new_object.build_meta_data if new_object.meta_data.blank?
    new_object.options = self.options.map do |option|
      new_option = option.dup
      new_option.exclusive_id = nil
      new_option
    end
    new_object.options.build if new_object.options.blank?
    new_object.title = ['Clone', self.title].join(' ')
    new_object.categories = self.categories
    new_object
  end

  def duplicate!
    duplicate.save!
  end

  def current?
    pending? && Time.zone.now >= start_at && Time.zone.now < end_at
  end

  def ended?
    Time.zone.now > end_at
  end

  def total_purchase_count
    shopping_bag_exclusives.purchased.map(&:qty).sum
  end

  def option_purchase_count(option)
    shopping_bag_exclusives.purchased.select { |j| j.option == option }.map(&:qty).sum
  end

  def purchase_count(option = nil)
    if use_option_quantity? && option
      option_purchase_count(option)
    else
      total_purchase_count
    end
  end

  def sold_out?(option = nil)
    return false if unlimited_in_stock?(option)
    quantity_available(option) && purchase_count(option) >= quantity_available(option)
  end

  def unlimited_in_stock?(option = nil)
    if options.with_quantity.any?
      option ? option.quantity.nil? : options.all? { |j| j.nil? }
    else
      maximum_quantity.nil?
    end
  end

  def max_in_stock(option = nil)
    return 0 if sold_out?(option)
    quantity_available(option) - purchase_count(option)
  end

  # Available product
  # If is not setup quantity that the product is always in stock
  # if sold_out that the product is not available
  #
  def in_stock?(quantity, option = nil)
    return true if unlimited_in_stock?(option) || quantity_available(option).nil?
    return false if sold_out?(option)
    (quantity_available(option).to_i - purchase_count(option).to_i) >= quantity
  end

  def in_stock(option = nil)
    return nil if quantity_available(option).nil?
    quantity_available(option) - purchase_count(option)
  end

  def available?
    !sold_out?
  end

  def pending!
    return if pending?
    update_attribute :status, 'pending'
  end

  def close!
    return unless pending?
    update_attribute :status, 'closed'
  end

  def closed?
    status == 'closed'
  end

  def current_discount
    (price - current_price) * 100 / price
  end

  def current_shop
    shops.current.first
  end

  def display_discount?
    current_shop ? current_shop.try(:display_discount?) : true
  end

  def current_shop_discount
    cs = current_shop
    cs ? cs.discount : 0
  end

  def custom_stage_message
    if Configurable.stage_messages.split("\n").include?(stage_message)
      ''
    else
      stage_message || ''
    end
  end

  def custom_stage_message=(message)
    self.stage_message = message unless message.blank?
  end

  def quantity=(value)
    if (new_qty = (Integer(value) rescue nil))
      unless persisted?
        self.maximum_quantity = new_qty
        return
      end
      return if @prev_quantity && new_qty == @prev_quantity
      current_in_stock = quantity_available.nil? ? 0 : in_stock
      case
      when self.maximum_quantity.nil?
        self.maximum_quantity = new_qty + purchase_count
      when current_in_stock > new_qty
        self.maximum_quantity = self.maximum_quantity.to_i - (current_in_stock - new_qty)
      when current_in_stock < new_qty
        self.maximum_quantity = self.maximum_quantity.to_i + (new_qty - current_in_stock)
      when new_qty == 0
        self.maximum_quantity = self.maximum_quantity.to_i - current_in_stock
      end
    else
      self.maximum_quantity = nil
    end
  end

  def days_left
    ((end_at - Time.zone.now) / (60 * 60 * 24)).round
  end

  def final_discount
    array = matrix_as_array
    array.last && ((price - array.last.last.to_f) * 100 / price)
  end

  def final_required
    array = matrix_as_array
    array.last && array.last.first.to_i
  end

  def first_two_days?
    started? && (start_at + 2.days) >= Time.zone.now
  end

  def pending?
    status == 'pending'
  end

  def total_quantity_available
    if use_option_quantity?
      options.map(&:quantity).compact.sum
    else
      maximum_quantity
    end
  end

  def quantity_available(option = nil)
    if use_option_quantity?
      if option
        option.quantity || 0
      else
        options.map(&:quantity).compact.sum
      end
    else
      maximum_quantity
    end
  end

  def use_option_quantity?
    options.with_quantity.any?
  end

  # @kind_calulate [Symbol] :all | :each - sum qty for all options or for each option
  #
  def left_less?(qty = 0, kind_calculate = :each)
    if use_option_quantity?
      if kind_calculate == :all
        left_less_with_all_options?(qty)
      else
        left_less_with_option?(qty, options.first)
      end

    else
      0 < left.to_i && left.to_i < qty
    end
  end

  def left_less_with_all_options?(qty)
    all_qty = options.map { |j| left_with_option(j).to_i }.sum
    0 < all_qty && all_qty < qty
  end

  def left_less_with_option?(qty, _option)
    0 < left_with_option(_option).to_i && left_with_option(_option).to_i < qty
  end

  def left(_option = nil)
    if use_option_quantity?
      left_with_option(_option || options.first)
    else
      quantity_available ? quantity_available - purchase_count : nil
    end
  end

  def total_left
    total_quantity_available - total_purchase_count
  end

  def left_with_option(_option)
    if quantity_available(_option)
      quantity_available(_option) - purchase_count(_option)
    else
      nil
    end
  end

  def started?
    start_at <= Time.zone.now && end_at > Time.zone.now
  end

  def total
    current_price #+ shipping_price
  end

  def upcoming?
    start_at > Time.zone.now
  end

  def description_for_purchase
    full_title
  end

  def images_for_scroll
    image_set = self.images - [self.image]
    image_set.insert(1, self.image).compact
  end

  def main_image
    return self.image if self.image
    return self.images.first unless self.images.empty?
  end

  def other_by_designer
    if self.designer_id.present?
      Exclusive.current.for_designer(self.designer_id).where("id != #{self.id}")
    end
  end

  def self.query(category = nil, designer_ids = [], order_by, all_exclusives)
    exclusives = all_exclusives ? Exclusive.current : Exclusive.unscoped.where('deleted_at IS NULL').in_shop
    if category
      exclusive_ids = CategoriesExclusive.select(:exclusive_id).where(:category_id => category.id).map(&:exclusive_id)
      exclusives = exclusives.where(:id => exclusive_ids)
    end
    exclusives = exclusives.order(order_by)
    exclusives = exclusives.where(:designer_id => designer_ids) unless designer_ids.empty?
    exclusives
  end

  def current_price
    price * (1 - current_shop_discount / 100.0)
  end

  private
  def self.designer_categories_map
    dc_map, ce_map = {}, {}
    exclusives = Exclusive.in_shop.select('id, designer_id')
    categories_exclusives = CategoriesExclusive.where(:exclusive_id => exclusives.map(&:id).sort).select('category_id, exclusive_id')

    categories_exclusives.all.each do |ce|
      ce_map[ce.exclusive_id] = [] unless ce_map[ce.exclusive_id]
      ce_map[ce.exclusive_id] <<  ce.category_id
    end

    exclusives.each do |e|
      key = "data-#{e.designer_id}"
      dc_map[key] = [] unless dc_map[key]
      dc_map[key] += ce_map[e.id] if ce_map[e.id]
    end

    dc_map.each do |k, v|
      dc_map[k] = v.uniq
    end
    dc_map
  end

end

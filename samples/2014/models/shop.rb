class Shop < ActiveRecord::Base
  MAX_PRIORITY = 100

  acts_as_paranoid

  extend FriendlyId
  friendly_id :name, use: :slugged

  serialize :priority, Hash

  has_one :meta_data, as: :parent
  has_one :mpu_frame, class_name: "ExternalServices::MpuFrame", dependent: :destroy

  has_one :image, as: :parent, conditions: { tag: nil }
  has_one :primary_image, class_name: "Image", as: :parent, conditions: { tag: 'primary' }
  has_one :secondary_image, class_name: "Image", as: :parent, conditions: { tag: 'secondary' }
  has_one :mpu_image, class_name: "Image", as: :parent, conditions: { tag: 'mpu' }

  has_many :shop_exclusives do
    def sort_exclusive_ids
      select('exclusive_id').order('position').map{ |j| j.exclusive_id }
    end
  end

  has_many :exclusives, through: :shop_exclusives, order: 'shop_exclusives.created_at DESC'
  has_and_belongs_to_many :categories
  belongs_to :designer

  accepts_nested_attributes_for :image, reject_if: :no_file?
  accepts_nested_attributes_for :meta_data, :primary_image, :secondary_image, :mpu_image
  validates_presence_of :description, :name, :start_at, :end_at

  after_commit  :update_cache

  default_scope where(closed: false)
  scope :only_closed, unscoped.where(closed: true)
  scope :available_now, ->{ where('start_at <= ? AND end_at > ?', Time.zone.now, Time.zone.now) }
  scope :current_available, ->{ unscoped.available_now  }

  def started?
    start_at <= Time.zone.now and end_at > Time.zone.now
  end

  def ended?
    Time.zone.now > end_at
  end

  def close
    self.closed = true
    self.save
  end

  def get_priority(domain)
    self.priority[domain] || MAX_PRIORITY
  end

  def set_priority(domain, value)
    self.priority[domain] = value.to_i
  end

  def tag_list=(val)
    self[:tag_list] = val
  end

  class << self

    def current
      where('start_at <= ? AND end_at > ?', Time.zone.now, Time.zone.now).order('start_at DESC')
    end

    def for_home(current_domain)
      current.includes(:image).sort { |a, b| a.get_priority(current_domain) <=> b.get_priority(current_domain) }[0, 5]
    end

    def current_exclusives
      shop_ids = Shop.current.map(&:id)
      return [] unless shop_ids.present?
      shop_exclusives = ShopExclusive.where("shop_id in (#{shop_ids.join(',')})").includes(:exclusive)
      shop_exclusives.map(&:exclusive)
    end

    def cache_key
      Shop.unscoped.maximum(:updated_at).to_i
    end

    def manage_popups_state
      conditions = 'end_at between updated_at and NOW() OR start_at between updated_at and NOW()'
      Shop.unscoped.where(conditions).all.map(&:switch_state)
    end

  end # end class << self

  def current_exclusives
    exclusives.
      current.
      reorder("field(exclusives.id, #{shop_exclusives.sort_exclusive_ids.join(',')}), exclusives.start_at DESC" )
  end

  def update_exclusive_positions!(previous_positions, current_positions, item_id)
    @item = item_id
    @shop_exclusive = shop_exclusives.where(exclusive_id: @item).first
    return if [@item, @shop_exclusive, previous_positions, current_positions].any?(&:blank?)

    @previous_position = (previous_positions||[]).index(@item)
    @current_position = (current_positions||[]).index(@item)

    if shop_exclusives.count == current_positions.size
      @shop_exclusive.insert_at(@current_position)
      touch
    else
      @steps = @current_position - @previous_position
      if @steps < 0
        @steps.abs.times{ @shop_exclusive.move_higher }
        touch
      elsif @steps > 0
        @steps.times{ @shop_exclusive.move_lower }
        touch
      end
    end
  end

  def switch_state
    touch
    exclusives.each{|e| e.update_column :show_in_boutique, !started?}
    exclusives.map(&:categories).flatten.uniq.map(&:touch)
  end

  private

  def update_cache
    exclusive_ids = exclusives.map(&:id)
    category_ids = categories.map(&:id)
    designer_ids = exclusives.map(&:designer_id).uniq

    Exclusive.where(id: exclusive_ids).update_all(updated_at: Time.now) unless exclusive_ids.empty?
    Category.where(id: category_ids).update_all(updated_at: Time.now) unless category_ids.empty?
    Designer.where(id: designer_ids).update_all(updated_at: Time.now) unless designer_ids.empty?
  end

  def no_file?(attributes)
    attributes[:file].blank?
  end
end

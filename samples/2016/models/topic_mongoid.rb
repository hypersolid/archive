class Topic
  include Mongoid::Document
  include TopicConcern
  include LegacyConcern
  include DispatchedModelConcern
  include Misc::PageScopeConcern

  BASE_TYPES = %w(
    Topics::Article
    Topics::Video
    Topics::Gallery
    Topics::Column
    Topics::Testdrive
    Topics::Infographic
    Topics::Online
    Topics::Interview
  )

  store_in collection: :topics

  field :specproject, type: String
  field :visible, type: Boolean
  field :exclusive, type: Boolean
  field :link, type: String

  embeds_one :picture, class_name: 'Embeds::Image'
  embeds_many :pictures, class_name: 'Embeds::Image'
  embeds_many :authors, class_name: 'Embeds::Author'
  embeds_many :widgets, class_name: 'Embeds::Widget'
  embeds_many :tags, class_name: 'Embeds::Tag'
  embeds_many :read_more_links, class_name: 'Embeds::ReadMoreLink'

  # rake db:mongoid:create_indexes
  # rake db:mongoid:remove_indexes
  DEFAULT_INDEXED_FIELDS = { _type: 1, visible: 1, published_at: -1 }

  index(**DEFAULT_INDEXED_FIELDS)
  index('exclusive': 1, **DEFAULT_INDEXED_FIELDS)
  index('subject.slug': 1, **DEFAULT_INDEXED_FIELDS)
  index('rubric.slug': 1, **DEFAULT_INDEXED_FIELDS)
  index('subrubric.slug': 1, **DEFAULT_INDEXED_FIELDS)
  index('authors.slug': 1, **DEFAULT_INDEXED_FIELDS)
  index('link': 1, **DEFAULT_INDEXED_FIELDS)

  index('lists.slug': 1, visible: 1, published_at: -1)

  default_scope -> { where(visible: true).desc(:published_at) }

  # Atomic scopes live here. More complex ones should be defined in relevant Query Object
  scope :base, -> { where(:_type.in => BASE_TYPES) }
  scope :by_rubric, -> (slug) { where('rubric.slug': slug) }
  scope :by_subrubric, -> (slug) { where('subrubric.slug': slug) }
  scope :by_author, ->(slug) { where('authors.slug': slug) }
  scope :by_link, -> (link) { where(link: link) }
  scope :by_tag, -> (slug) { where('tags.slug': slug) }
  scope :by_specproject, -> (specproject) { where('specproject.slug': specproject) }
  scope :by_columnist, -> (slug) { where('columnist.slug': slug) }
  scope :except, ->(link) { ne(link: link) }
  scope :by_published_date, lambda { |date|
    start_time = date.to_datetime.beginning_of_day
    end_time = date.to_datetime.end_of_day
    where(published_at: start_time..end_time)
  }

  scope :by_sport, -> (slug) { where('sport.slug': slug) }
  scope :by_tournament, -> (slug) { where('tournament.slug': slug) }

  scope :page_by_published_at, lambda { |timestamp, amount|
    where(:published_at.lt => timestamp.to_i).limit(amount)
  }

  %w(text image topic gallery quote).each do |widget_type|
    define_method "#{widget_type}_widgets" do
      widgets.select do |widget|
        widget._type == "Embeds::Widgets::#{widget_type.titlecase}"
      end
    end
  end

  def self.page_by_published_at_and_more(timestamp, amount)
    items = page_by_published_at(timestamp, amount)
    more = items.count > amount

    [items, more]
  end

  def picture_src(version = :original)
    picture.src(version) if picture
  end

  def widgets?
    widgets.present?
  end

  def tagged_with?(tag)
    tags.any? { |t| t.slug == tag.slug }
  end

  # FIXME: deprecated, remove after rewriting mobile api
  def subject=(subject)
    self.subjects = [subject]
  end

  def subject?
    subjects.present?
  end

  def subject
    subjects.try(:first)
  end
end

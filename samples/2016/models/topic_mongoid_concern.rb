module TopicConcern
  extend ActiveSupport::Concern

  included do
    # We don't use default links array. Instead, to improve performance we use
    # main link and store all redirect paths in a separate collection
    field :link, type: String
    field :headline, type: String
    field :alternative_headline, type: String
    field :announce, type: String

    field :modified_at, type: DateTime
    field :published_at, type: DateTime, default: Time.zone.now

    embeds_one :picture, class_name: 'Embeds::Image'
    embeds_one :rubric, class_name: 'Embeds::Rubric'
    embeds_one :subrubric, class_name: 'Embeds::Subrubric'
    embeds_one :specproject, class_name: 'Embeds::Specproject'
    embeds_one :specproject_rubric, class_name: 'Embeds::Rubric'
    embeds_many :subjects, class_name: 'Embeds::Subject'

    scope :by_subject, -> (slug) { where('subjects.slug': slug) }
  end

  def multimedia?
    video? || infographic? || gallery?
  end

  # TODO: Maybe dispatch another field with type?
  def video?
    attributes['_type'].split('::').last == 'Video'
  end

  def infographic?
    attributes['_type'].split('::').last == 'Infographic'
  end

  def gallery?
    attributes['_type'].split('::').last == 'Gallery'
  end
end

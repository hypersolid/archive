class TopicDecorator < Draper::Decorator
  include ActionView::Helpers::SanitizeHelper

  delegate_all

  decorates_associations :picture, :rubric, :subrubric,
    :subject, :authors, :widgets, :read_more_links

  def body
    widgets.to_a.map { |widget| h.render widget.desktop_partial, widget: widget }.join.html_safe
  end

  # NOTE: We use it to retrieve comments for article
  def xid
    gid.presence || pid
  end

  def raw_body
    widgets.to_a.map(&:content).join.html_safe
  end

  def headline
    h.typographize object.headline
  end

  alias_method :to_s, :headline

  def alternative_headline
    h.typographize object.alternative_headline
  end

  def announce
    h.escape_html(h.typographize(object.announce))
  end

  def announce_short
    h.truncate_announce(announce) if announce
  end

  def url
    h.full_url(link)
  end

  %w(large medium small subject multimedia).each do |version|
    define_method("picture_#{version}_src") do
      picture.src(version) if picture
    end
  end

  def broadcasting?
    object.try :broadcasting?
  end

  def tags
    object.try :tags
  end

  def authors_names
    authors.map(&:to_s).join(', ') if object.authors.present?
  end

  def author
    authors.first
  end

  # TODO
  def views
    object_views = 100_000
    h.number_with_delimiter(object_views, delimiter: ' ')
  end

  # TODO: Fix after import from cms is ready
  def comments_count
    42
  end

  def published_timestamp
    object.published_at.to_i
  end

  def published_datetime
    l object.published_at
  end

  def published_time
    l object.published_at, format: :short
  end

  def published_in_words
    h.published_in_words object.published_at
  end

  def published_in_words?
    h.published_in_words? object.published_at
  end

  def published_in_words_or_datetime
    h.published_in_words_or_datetime(object.published_at)
  end

  def partial
    _type.split('::').last.parameterize('_')
  end

  def to_partial_path
    "/shared/topics/#{partial}.html.slim"
  end

  def template
    _type.parameterize.split('-').last
  end

  def cyrillic_type
    h.t "misc.types.#{_type.parameterize('_')}"
  end

  %w(video gallery infographic column).each do |kind|
    define_method("#{kind}?") do
      false
    end
  end

  def hide_author?
    %w(Topics::Column Topics::Infographic Topics::Video Topics::Gallery).include? object._type
  end

  def mate_link
    "#{Settings.main.mate_domain}/#!/topic/#{topic.pid}"
  end

  def ribbon
    'Эксклюзив' if object.exclusive?
  end

  def ribbon?
    !ribbon.blank?
  end
end

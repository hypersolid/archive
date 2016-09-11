module Topics
  class ColumnDecorator < TopicDecorator
    decorates_association :columnist

    delegate_all

    # FIXME: After all columns have columnists
    def authors
      columnist.present? ? [columnist] : super
    end

    # FIXME
    def m_path
      h.mobile_url(link)
    end

    def slide_text
      authors.first
    end

    def to_s
      headline
    end

    def rss_description
      sanitized_body = h.strip_tags(body)

      h.truncate(sanitized_body, length: 220, separator: ' ')
    end

    def column?
      true
    end

    def announce
      h.typographize object.alternative_headline
    end
  end
end

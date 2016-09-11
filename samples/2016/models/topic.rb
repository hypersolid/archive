module Aqua
  module Orm
    class Topic < ActiveRecord::Base
      include Aqua::Orm::Concerns::CoverConcern
      include Aqua::Orm::Concerns::DebugConcern
      include Aqua::Orm::Concerns::ImportConcern
      include Aqua::Orm::Concerns::QueryConcern
      include Aqua::Orm::Concerns::TemplateConcern
      include Aqua::Orm::Concerns::TopicFieldsConcern

      establish_connection :gazeta_articles

      self.table_name = :all_articles

      scope :for_stripe, ->(stripe) { where(article_stripe: stripe.id) }

      def subject
        Articles::Subject.find(content.subject) if content.subject
      end

      def publish_points
        article_publish_points.split(',').map do |point_id|
          Articles::Plain.find_by_id(point_id).try :title
        end.compact
      end

      def link_incuts
        result = []

        incuts_hash('link').each do |key, link_id|
          i = key[/(\d+)/, 1].to_i
          result[i] = Articles::Plain.find(link_id)
        end

        result
      end

      def text_incuts
        result = []

        incuts_hash('text').each do |key, text|
          i = key[/(\d+)/, 1].to_i
          name = content["incut#{i}_name"]

          result[i] = Hashie::Mash.new(name: name, body: text)
        end

        result
      end

      def image_incuts
        result = []
        owner = picture.data.owner

        incuts_hash('pic').each do |key, src|
          i = key[/(\d+)/, 1].to_i
          result[i] = Hashie::Mash.new(src: src, owner: owner)
        end

        result
      end

      def incuts_hash(type)
        content.select { |key, value| key.match(/^incut\d+_#{type}/) && value.present? }
      end

      def incuts_type
        return 'links'  if incuts_hash('link').present?
        return 'texts'  if incuts_hash('text').present?
        return 'images' if incuts_hash('pic').present?
      end

      def rubric
        stripe.parent
      end

      def picture
        picture_id = if content.media_pic && !content.media_pic.empty?
                       # regular picture
                       content.media_pic
                     else
                       # regular picture, but hidden in author's column
                       stripe.content.media_pic
                     end
        Articles::Picture.find picture_id if picture_id.present?
      rescue
        nil
      end

      def pic_src
        picture ? picture.data.src : 'NULL'
      end

      # Sport
      def competition
        ::Aqua::Orm::Sport::Rubrics::Competition.find_by(id: content.competition) if content.competition
      end

      def sport
        if content.competition && competition
          competition.sports.first
        elsif content.sports
          ::Aqua::Orm::Sport::Rubrics::Sport
            .where(id: content.sports.split(',')).first
        elsif content.sport
          ::Aqua::Orm::Sport::Rubrics::Sport
            .where(id: content.sport).first
        end
      end
    end

    def stripe
      Aqua::Orm::Stripe.find(article_stripe)
    end
  end
end

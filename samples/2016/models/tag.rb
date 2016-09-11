module Tags
  class Tag < ActiveRecord::Base
    self.table_name = :tags

    has_many :taggings
    has_many :topics, through: :taggings, class_name: 'Topics::Topic'

    has_ancestry cache_depth: true

    scope :search, -> (q) { where(['title ILIKE ?', "%#{q}%"]) }

    scope :default_order, -> { order('title ASC') }
    default_scope -> { where(deleted: false) }

    validates :title, presence: true, uniqueness: { scope: :ancestry }
    validates :slug, presence: true, uniqueness: { scope: :ancestry }, format: { with: /\A[\w-]+\z/i }

    class << self
      def metadata
        { type: name,
          slug: name.demodulize.underscore,
          color: "##{SecureRandom.hex(3)}",
          title: name.demodulize,
          hidden: false
        }.with_indifferent_access
      end

      def slug
        metadata[:slug]
      end

      def mark_as_hidden
        @hidden = true
        def self.metadata
          super.merge(hidden: @hidden || false)
        end
      end

      def permitted_params
        %i(title slug parent_id)
      end

      def child_class
        nil
      end

      def additional_serializable_fields
        []
      end

      def active_model_serializer_v2
        ::Tags::V2::TagSerializer
      end
    end

    def destroy
      update_attribute :deleted, true
    end

    def type_slug
      self.class.metadata[:slug]
    end

    def hidden
      self.class.metadata[:hidden]
    end

    def active_model_serializer
      TagSerializer
    end
  end
end

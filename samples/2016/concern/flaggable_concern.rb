module FlaggableConcern
  extend ActiveSupport::Concern

  class_methods do
    def define_flag(name)
      store_accessor :params, name
      scope name, -> { where("(#{table_name}.params->>'#{name}')::bool = ?", true) }
      define_method "#{name}?" do
        send(name) == true
      end
    end
  end
end

class Gazeta::QueryObject
  attr_accessor :amounts
  attr_reader :namespace

  class << self
    def relation
      @relation = yield
    end

    def scopes_for(klass, &block)
      validate_scopes(klass, block)
      klass.class_exec(&block)
    end

    def fetch_relation
      init_relation
      @relation
    end

    private

    def scope(name, _body)
      return unless @scope_target.scopes[name.to_sym]
      fail "You're trying to override the existing scope #{@scope_target}##{name} at "\
           "#{@scope_target.scopes[name.to_sym][:scope].source_location.join(':')}"
    end

    def validate_scopes(klass, block)
      @scope_target = klass
      class_exec(&block)
    end

    def init_relation
      @relation ||= to_s.sub('Query', '').safe_constantize

      fail "Relation for #{self} was not found.\n" \
           'N.b. You must name QO classes accordingly to the related model ' \
           '(e.g. Topics::ArticleQuery for Topics::Article) ' \
           'or specify `relation { Topic }` explictly in its definition.' unless @relation
    end
  end

  def initialize(namespace)
    @relation = self.class.fetch_relation
    @namespace = namespace

    self.amounts = Settings.amounts.send(namespace)
  end
end

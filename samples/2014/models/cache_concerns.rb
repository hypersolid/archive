# encoding: UTF-8
module Concerns::CacheConcerns

  def self.included(base)
    base.instance_eval do
      after_commit :touch_cache_key
      after_touch :touch_cache_key
      class << self
        def cache_key
          response = $redis_keys.get(to_s)
          return response if response

          Time.now.to_i.tap { |j| $redis_keys.set(to_s, j) }
        end
      end
    end
  end

  def touch_cache_key
    $redis_keys.set self.class.to_s, Time.now.to_i
  end
end

module Gazeta
  # The main purpose of GCache is to throttle database requests
  # or other long-running operations to a certain rate per minute
  module Cache
    def gcache(*slugs, rpm: 60, &block)
      cache_time = 1.minute / rpm

      cache_key = gcache_key(slugs, block)

      Rails.logger.debug "G-caching #{block.source_location.first}:#{block.source_location.last} " \
        "-> #{cache_key}, expires in: #{cache_time.seconds.to_i}s"

      results = Rails.cache.fetch(cache_key, expires_in: cache_time, &block)

      gcache_match(slugs, results)
    end

    private

    def gcache_key(slugs, block)
      key = [*slugs].map(&:to_s).join('_')

      @gcache_keys ||= {}
      @gcache_keys[key] ||= Digest::SHA256.hexdigest(key + block.source)

      "gcache/#{@gcache_keys[key]}"
    end

    def gcache_match(slugs, results)
      results = [results] if slugs.count == 1
      slugs.each_with_index { |slug, index| instance_variable_set "@#{slug}", results[index] }
    end
  end
end

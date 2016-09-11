class Parser
  class << self
    def parse(link)
      feed = Feedjira::Feed.fetch_and_parse(link)
      return if feed.is_a? Fixnum
      feed.entries.each do |entry|
        next if !entry.url || Entry.where(url: entry.url.strip).exists?

        stocks = YahooFinance.quotes(["EURUSD=X"], [:bid, :ask]).first.to_h

        puts "#{Time.now} > #{entry.title} #{stocks}"

        Entry.create(
          title: entry.title.try(:strip),
          summary: entry.summary.try(:strip),
          url: entry.url.strip,
          source: link.strip,
          published: entry.published,
          payload: stocks
        )
      end
    end

    def start
      yaml = YAML.load_file("#{Rails.root}/config/feeds.yml")
      feeds = yaml['feeds']
      loop do
        feeds.each do |feed|
          parse(feed)
        end

        sleep 60
      end
    end
  end
end

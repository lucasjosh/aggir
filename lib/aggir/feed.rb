module Aggir
  class Feed < Sequel::Model
    
    class << self
      def create_or_update(f)
        fd = find_by_feed_url(f)
        return fd if fd
        feed = FeedParser.parse(f)
        puts "Creating #{feed.feed.title} : #{feed.feed.link}"
        f = Feed.new({:title => feed.feed.title,
                      :url => feed.feed.link,
                      :feed_url => f})
        f.save
      end
      
      def find_by_feed_url(feed_url)
        Feed.find :feed_url => feed_url
      end
    end
  end
end
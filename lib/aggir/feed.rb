require 'parsedate'

module Aggir
  class Feed < Sequel::Model
    
    one_to_many :entries, :class => "Aggir::Entry"
    
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
    
    def update_entries
      raw_feed = FeedParser.parse(feed_url)
      raw_feed.entries.each do |entry|
        content = (entry.content && entry.content.first) ? entry.content.first.value : entry.summary
        e = Aggir::Entry.find_guid(entry.guid)
        unless e
          e = Aggir::Entry.new(:title => entry.title, :link => entry.link,
                                  :guid => entry.guid, :content => content,
                                  :summary => entry.summary, :published => entry.updated,
                                  :created => entry.updated, :feed => self)
          add_entry(e)
          save
        else
          res = ParseDate.parsedate(entry.updated)
          ct = Time.local(*res)
          if e.need_update?(ct)
            e.save(:title => entry.title, :link => entry.link,
                   :guid => entry.guid, :content => content,
                   :summary => entry.summary, :published => entry.updated,
                   :created => entry.updated, :feed => self)
          end
        end
      end
      self
    end
    
  end
end

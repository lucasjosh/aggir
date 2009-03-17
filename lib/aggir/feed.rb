require 'parsedate'
require 'redis'
require 'digest/md5'

module Aggir
  class Feed
    
    FEED_ID_KEY = "global:feed_id"
    
    attr_accessor :r, :id, :title, :url, :feed_url
    
    #one_to_many :entries, :class => "Aggir::Entry"
    def initialize(id, title, url, feed_url)
      @id = id
      @title = title
      @url = url
      @feed_url = feed_url
    end
    
    
    class << self
      def get_next_id
        r = Redis.new
        r.set_unless_exists FEED_ID_KEY, 1000
        r.incr FEED_ID_KEY
      end
      
      def create_or_update(f)
        fd = find_by_feed_url(f)
        return fd if fd
        feed = FeedParser.parse(f)
        puts "Creating #{feed.feed.title} : #{feed.feed.link}"
        id = get_next_id        
        saved_f = Feed.new(id, feed.feed.title,
                           feed.feed.link, f)
        saved_f.save
      end
      
      def find_by_feed_url(feed_url)
        r = Redis.new
        key = "#{Digest::MD5.hexdigest(feed_url)}"
        if r.key?("feed:#{key}")
          title, url, feed_url = r["feed:#{key}"].split("|")
          id = r["feed:#{key}:id"]
          return Feed.new(id, title, url, feed_url)
        end
        nil
      end
      
    end
    
    def save
      key = "#{Digest::MD5.hexdigest(url)}"
      r = Redis.new
      r["feed:#{key}"] = "#{title}|#{url}|#{feed_url}"
      r["feed:#{key}:id"] = id
      self
    end
    
    def add_entry(e)
      key = "#{Digest::MD5.hexdigest(url)}"
      r = Redis.new
      r.push_tail("feed:#{key}:entries", e.hashed_guid)
    end
    
    def entries
      key = "#{Digest::MD5.hexdigest(url)}"
      r = Redis.new
      ret_entries = Array.new
      t_entries = r.list_range("feed:#{key}:entries", 0, -1)
      t_entries.each do |entry|
        ret_entries << Aggir::Entry.find_hash(entry)
      end
      ret_entries
    end
    
    def update_entries
      raw_feed = FeedParser.parse(feed_url)
      raw_feed.entries.each do |entry|
        content = (entry.content && entry.content.first) ? entry.content.first.value : entry.summary
        e = Aggir::Entry.find_hash(entry.guid)
        unless e
          e = Aggir::Entry.new(:title => entry.title, :link => entry.link,
                                  :guid => entry.guid, :content => content,
                                  :summary => entry.summary, :published => entry.updated,
                                  :created => entry.updated, :feed_id => self.id, :hashed_guid => Digest::MD5.hexdigest(entry.link))
          e.save
          #e.find_links
          add_entry(e)
          puts "Adding #{e.title}"
          save
        else
          res = ParseDate.parsedate(entry.updated)
          ct = Time.local(*res)
          if e.need_update?(ct)
            e.save(:title => entry.title, :link => entry.link,
                   :guid => entry.guid, :content => content,
                   :summary => entry.summary, :published => entry.updated,
                   :created => entry.updated, :feed_id => self.id, :hashed_guid => Digest::MD5.hexdigest(entry.link))
          end
        end
      end
      self
    end
    
  end
end

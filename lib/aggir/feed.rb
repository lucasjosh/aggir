require 'parsedate'
require 'redis'
require 'digest/md5'

module Aggir
  class Feed
    
    FEED_ID_KEY = "global:feed_id" unless defined? FEED_ID_KEY
    FEED_PREFIX = "feed" unless defined? FEED_PREFIX
    FEEDS_PREFIX = "feeds" unless defined? FEEDS_PREFIX
    ENTRIES_PREFIX = "entries" unless defined? ENTRIES_PREFIX
    
    attr_accessor :r, :id, :title, :url, :feed_url
    
    def initialize(id, title, url, feed_url)
      @id = id
      @title = title
      @url = url
      @feed_url = feed_url
    end
    
    
    class << self
      def get_next_id
        Aggir::RedisStorage.get_next_id(FEED_ID_KEY)
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
        key = "#{Digest::MD5.hexdigest(feed_url)}"
        find(key)
      end
      
      def all
        Aggir::RedisStorage.all("#{FEEDS_PREFIX}:all", Aggir::Feed)
      end
      
      def find(hashed_url)
        if exists?(hashed_url)
          title, url, feed_url = Aggir::RedisStorage.get("#{FEED_PREFIX}:#{hashed_url}").split("|")
          id = Aggir::RedisStorage.get("#{FEED_PREFIX}:#{hashed_url}:id")
          return Feed.new(id, title, url, feed_url)
        end
        nil        
      end
      
      def exists?(hash)
        Aggir::RedisStorage.exists?("#{FEED_PREFIX}:#{hash}")
      end
      
      def find_by_hash(hashed_url)
        find(hashed_url)
      end
      
      def sort_entries
        ret_entries = Aggir::RedisStorage.all("#{ENTRIES_PREFIX}:all", Aggir::Entry)
        sorted_entries = ret_entries.sort {|a,b| 
          a_res = ParseDate.parsedate(a.published)
          b_res = ParseDate.parsedate(b.published)
          Time.local(*b_res) <=> Time.local(*a_res)
        }.collect {|a| a.hashed_guid}
        Aggir::RedisStorage.delete("#{ENTRIES_PREFIX}:sorted")
        sorted_entries.each {|se| Aggir::RedisStorage.push_to_end("#{ENTRIES_PREFIX}:sorted", se)}
      end
      
      def latest(hashed_url)
        page_num = 1
        ret_entries = Array.new
        start = (page_num == 1) ? 0 : page_num * 15
        last = (page_num + 1) * 15
        Aggir::RedisStorage.latest("#{FEED_PREFIX}:#{hashed_url}:entries", Aggir::Entry, start, last)
      end
      
      def most_recent
        Aggir::RedisStorage.latest("#{FEEDS_PREFIX}:all", Aggir::Feed, -10, -1).reverse
      end
            
    end
    
    def save
      key = "#{Digest::MD5.hexdigest(url)}"
      Aggir::RedisStorage.save("#{FEED_PREFIX}:#{key}", "#{title}|#{url}|#{feed_url}")
      Aggir::RedisStorage.save("#{FEED_PREFIX}:#{key}:id", id)
      Aggir::RedisStorage.push_to_end("#{FEEDS_PREFIX}:all", key)
      self
    end
    
    def add_entry(e)
      key = "#{Digest::MD5.hexdigest(url)}"
      Aggir::RedisStorage.push_to_end("#{FEED_PREFIX}:#{key}:entries", e.hashed_guid)
      Aggir::RedisStorage.push_to_front("#{ENTRIES_PREFIX}:all", e.hashed_guid)
    end
    
    def entries
      key = "#{Digest::MD5.hexdigest(url)}"
      Aggir::RedisStorage.all("#{FEED_PREFIX}:#{key}:entries", Aggir::Entry)
    end
    
    def update_entries
      raw_feed = FeedParser.parse(feed_url)
      raw_feed.entries.each do |entry|
        content = (entry.content && entry.content.first) ? entry.content.first.value : entry.summary
        e = Aggir::Entry.find(entry.link)
        unless e
          e = Aggir::Entry.new(:title => entry.title, :link => entry.link,
                                  :guid => entry.guid, :content => content,
                                  :summary => entry.summary, :published => entry.updated,
                                  :created => entry.updated, :feed_id => Digest::MD5.hexdigest(url), :hashed_guid => Digest::MD5.hexdigest(entry.link))
          e.save
          e.find_links
          add_entry(e)
          puts "Adding #{e.title} - #{e.link}"
        else
          res = ParseDate.parsedate(entry.updated)
          ct = Time.local(*res)
          if e.need_update?(ct)
            puts "Updating #{entry.title}"
            e.update({:title => entry.title, :link => entry.link,
                   :guid => entry.guid, :content => content,
                   :summary => entry.summary, :published => entry.updated,
                   :created => entry.updated, :feed_id => Digest::MD5.hexdigest(url), :hashed_guid => Digest::MD5.hexdigest(entry.link)})
          end
        end
      end
      self
    end    
    
  end
end

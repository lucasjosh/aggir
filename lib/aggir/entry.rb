require 'nokogiri'
require 'digest/md5'
require 'json'
require 'parsedate'

module Aggir
  class Entry 
    
    ENTRY_ID_KEY = "global:entry_id" unless defined? ENTRY_ID_KEY
    ENTRIES_PREFIX = "entries" unless defined? ENTRIES_PREFIX
    ENTRY_PREFIX = "entry" unless defined? ENTRY_PREFIX
    ENTRIES_LIST = "#{ENTRIES_PREFIX}:all"
    
    REDIS = Redis.new
    
    attr_accessor :id, :title, :link, :name, :content
    attr_accessor :summary, :published, :created, :feed_id, :guid
    attr_accessor :hashed_guid
    attr_accessor :r, :feed
    
    def initialize(params)
      @id = params[:id] || ""
      @title = params[:title] || ""
      @link = params[:link] || ""
      @name = params[:name] || ""
      @content = params[:content] || ""
      @summary = params[:summary] || ""
      @published = params[:published] || ""
      @created = params[:created] || ""
      @feed_id = params[:feed_id] || ""
      @guid = params[:guid] || ""
      @hashed_guid = params[:hashed_guid] || "" 
    end
    
    def save
      id = Entry.get_next_id unless id
      h_guid = Digest::MD5.hexdigest(link)
      REDIS["#{ENTRY_PREFIX}:#{h_guid}"] = "#{title}|#{link}|#{name}|#{content}|#{summary}|#{published}|#{created}|#{feed_id}|#{guid}|#{hashed_guid}"
      REDIS["#{ENTRY_PREFIX}:#{h_guid}:id"] = id
      self
    end    
    
    def feed
      Aggir::Feed.find(feed_id)
    end
    
    class << self      
      
      def find(link)
        h_guid = Digest::MD5.hexdigest(link)
        find_hash(h_guid)
      end
      
      def find_hash(hashed_link)
        
        if REDIS.key?("#{ENTRY_PREFIX}:#{hashed_link}")
          title, link, name, content, summary, published, created, feed_id, guid, hashed_guid = REDIS["#{ENTRY_PREFIX}:#{hashed_link}"].split("|")
          id = REDIS["#{ENTRY_PREFIX}:#{hashed_link}:id"]
          return Aggir::Entry.new({:id => id, :title => title, :link => link, :name => name, :summary => summary,
                            :content => content, :published => published, :created => created,
                            :feed_id => feed_id, :guid => guid, :hashed_guid => hashed_guid})
        end
        nil        
      end
      
      def get_next_id
        REDIS.set_unless_exists ENTRY_ID_KEY, 1000
        REDIS.incr ENTRY_ID_KEY
      end
      
      
      def get_latest(page_num = 1)
        #Aggir::Entry.reverse_order(:published).paginate(page_num, 15)
        ret_entries = Array.new
        t_entries = REDIS.list_range(ENTRIES_LIST, page_num - 1, page_num * 15)
        t_entries.each do |entry|
          ret_entries << Aggir::Entry.find_hash(entry)
        end
        ret_entries
        
      end
      
      def search(query, page)
        
        resp = Aggir::Solr.new.search(query, page)
        json = JSON.parse(resp)
        parse_solr(json)
      end
      
      def parse_solr(json)
        ret = {}
        ret['Count'] = json['response']['numFound']
        ret['Entries'] = json['response']['docs'].map {|doc| {:title => doc['title'], :link => doc['link'], 
                                                                       :hashed_link => doc['id']}}
        ret                                                            
      end      
      
    end
    
    def need_update?(publish_time)
      res = ParseDate.parsedate(published)
      Time.local(*res) < publish_time
    end
    
    def find_links
      doc = Nokogiri::HTML(content)
      doc.xpath("//a").each do |link|
        url = link['href'].to_s
        if url.index(/.pdf$/)
          add_link(Aggir::Link.new(:link => url))
        end
      end
      save
    end    
    
  end
end

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
      Aggir::RedisStorage.save("#{ENTRY_PREFIX}:#{h_guid}", "#{title.gsub("|", "-")}|#{link}|#{name}|#{content.gsub("\n", "").gsub("|","-")}|#{summary.gsub("\n", "").gsub("|","-")}|#{published}|#{created}|#{feed_id}|#{guid}|#{hashed_guid}")
      Aggir::RedisStorage.save("#{ENTRY_PREFIX}:#{h_guid}:id", id)
      self
    end    
    
    def update(params)
      id = params[:id] || @id
      title = params[:title] || @title
      link = params[:link] || @link
      name = params[:name] || @name
      content = params[:content] || @content
      summary = params[:summary] || @summary
      published = params[:published] || @published
      created = params[:created] || @created
      feed_id = params[:feed_id] || @feed_id
      guid = params[:guid] || @guid
      hashed_guid = params[:hashed_guid] || @hashed_guid
      
      id = Entry.get_next_id unless id
      h_guid = Digest::MD5.hexdigest(link)
      Aggir::RedisStorage.save("#{ENTRY_PREFIX}:#{h_guid}", "#{title.gsub("|", "-")}|#{link}|#{name}|#{content.gsub("\n", "").gsub("|","-")}|#{summary.gsub("\n", "").gsub("|","-")}|#{published}|#{created}|#{feed_id}|#{guid}|#{hashed_guid}")
      Aggir::RedisStorage.save("#{ENTRY_PREFIX}:#{h_guid}:id", id)
      self
      
      
    end
    
    def feed
      Aggir::Feed.find(feed_id)
    end
    
    class << self      
      
      def find(link)
        h_guid = Digest::MD5.hexdigest(link)
        find_by_hash(h_guid)
      end
      
      def find_by_hash(hashed_link)
        
        if exists?(hashed_link)
          title, link, name, content, summary, published, created, feed_id, guid, hashed_guid = Aggir::RedisStorage.get("#{ENTRY_PREFIX}:#{hashed_link}").split("|")
          id = Aggir::RedisStorage.get("#{ENTRY_PREFIX}:#{hashed_link}:id")
          return Aggir::Entry.new({:id => id, :title => title, :link => link, :name => name, :summary => summary,
                            :content => content, :published => published, :created => created,
                            :feed_id => feed_id, :guid => guid, :hashed_guid => hashed_guid})
        end
        nil        
      end
      
      def exists?(hashed_link)
        Aggir::RedisStorage.exists?("#{ENTRY_PREFIX}:#{hashed_link}")
      end
      
      def get_next_id
        Aggir::RedisStorage.get_next_id(ENTRY_ID_KEY)
      end
      
      
      def latest(page_num = 1)  
        start = (page_num == 1) ? 0 : page_num * 15
        last = (page_num + 1) * 15
        Aggir::RedisStorage.latest("#{ENTRIES_PREFIX}:sorted", Aggir::Entry, start, last)
      end
      
      def all
        Aggir::RedisStorage.all("#{ENTRIES_PREFIX}:all", Aggir::Entry)
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
    
    def add_link(new_link)
      h_guid = Digest::MD5.hexdigest(link)
      Aggir::RedisStorage.push_to_front("#{ENTRY_PREFIX}:#{h_guid}:links", new_link.id)
    end
    
    def find_keywords
      keywords = Array.new
      doc = Nokogiri::HTML(content)
      d = Aggir::Delicious.new
      doc.xpath("//a").each do |link|
        url = link['href'].to_s
        puts "URL => #{url}"
        kwd = d.keywords(url)
        keywords << kwd if kwd
      end
      break_down_keywords(keywords)
    end
    
    def break_down_keywords(keywords, floor = 0.5, ceiling = 0.8)
      ret_keywords = Array.new
      keywords.each do |num, kwds|
        if num.to_i > 1
          kwds.each do |key, value|
            num = 1 if num = '0'
            num = value.to_f / num.to_i
            ret_keywords << key if floor < num && num > ceiling
          end
        end
      end
      ret_keywords.uniq
    end
    
    def find_links
      doc = Nokogiri::HTML(content)
      doc.xpath("//a").each do |link|
        url = link['href'].to_s
        if url.index(/.pdf$/)
          puts "Adding Link: #{url}"
          l = Aggir::Link.new(url, hashed_guid).save
          add_link(l)
        end
      end
      save
    end    
    
  end
end

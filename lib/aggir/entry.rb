require 'nokogiri'
require 'digest/md5'
require 'json'
module Aggir
  class Entry 
    
    ENTRY_ID_KEY = "global:entry_id"
    
    attr_accessor :id, :title, :link, :name, :content
    attr_accessor :summary, :published, :created, :feed_id, :guid
    attr_accessor :hashed_guid
    
    def initialize(params)
      params.each do |k, v|
        self.send("#{k}=", v)
      end
    end
    
    def save
      id = Entry.get_next_id unless id
      h_guid = Digest::MD5.hexdigest(link)
      r = Redis.new
      r["entry:#{h_guid}"] = "#{title}|#{link}|#{content}|#{summary}|#{published}|#{created}|#{feed_id}|#{guid}|#{hashed_guid}"
      r["entry:#{h_guid}:id"] = id
      self
    end    
    
    class << self
      
      def find(link)
        h_guid = Digest::MD5.hexdigest(link)
        find_hash(h_guid)
      end
      
      def find_hash(hashed_link)
        r = Redis.new
        if r.key?("entry:#{hashed_link}")
          title, link, name, content, summary, published, created, feed_id, guid, hashed_guid = r["entry:#{hashed_link}"].split("|")
          id = r["entry:#{hashed_link}:id"]
          return Entry.new({:id => id, :title => title, :link => link, :name => name, :summary => summary,
                            :content => content, :published => published, :created => created,
                            :feed_id => feed_id, :guid => guid, :hashed_guid => hashed_guid})
        end
        nil        
      end
      
      def get_next_id
        r = Redis.new
        r.set_unless_exists ENTRY_ID_KEY, 1000
        r.incr ENTRY_ID_KEY
      end
      
      
      def get_latest(page_num = 1)
        Aggir::Entry.reverse_order(:published).paginate(page_num, 15)
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
      published < publish_time
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

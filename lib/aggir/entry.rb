require 'nokogiri'
require 'digest/md5'
require 'json'
module Aggir
  class Entry < Sequel::Model
    many_to_one :feed, :class => "Aggir::Feed"
    one_to_many :links, :class => "Aggir::Link"
    
    class << self
      def find_guid(guid)
        Entry.find :guid => guid
      end
      
      def find_hashed_guid(link)
        h_guid = Digest::MD5.hexdigest(link)
        Entry.find :hashed_guid => h_guid
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
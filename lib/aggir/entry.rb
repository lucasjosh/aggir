require 'nokogiri'

module Aggir
  class Entry < Sequel::Model
    many_to_one :feed, :class => "Aggir::Feed"
    one_to_many :links, :class => "Aggir::Link"
    
    class << self
      def find_guid(guid)
        Entry.find :guid => guid
      end
      
      def get_latest(page_num = 1)
        Aggir::Entry.reverse_order(:published).paginate(page_num, 15)
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
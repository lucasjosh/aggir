require 'uri'
require 'open-uri'
require 'digest/md5'

module Aggir
  class Link
    LINK_PREFIX = "link"
    LINKS_PREFIX = "links"
    
    attr_accessor :id, :link, :entry_id
    
    REDIS = Redis.new
    
    class << self
      def latest(num = 15)
        #Link.reverse_order(:id).limit(num)
        ret_links = Array.new
        if REDIS.key?("#{LINKS_PREFIX}:all")
          t_links = REDIS.list_range("#{LINKS_PREFIX}:all", 0, num)
          t_links.each do |link|
            ret_links << Aggir::Link.find(id)
          end
        end
        ret_links        
      end
      
      def all
        latest(-1)
      end
      
      def find(id)
        if Redis.key?("#{LINK_PREFIX}:#{id}")
          id, link, entry_id = REDIS["#{LINK_PREFIX}:#{id}"]
          return Link.new(link, entry_id)
        end
        nil
      end
    end
    
    def initialize(link, entry_id)
      @link = link
      @entry_id = entry_id      
      @id = Digest::MD5.hexdigest(link)
    end
    
    def save
      REDIS["#{LINK_PREFIX}:#{id}"] = "#{id}|#{link}|#{entry_id}"
      REDIS.push_head("#{LINKS_PREFIX}:all", id)
    end
    
    def download(download_dir)
      url = URI.parse(link)
      local_file = url.path.split("/").last
      unless File.exists?(File.join(download_dir, local_file))
        begin
          str = open(link).read      
          open(File.join(download_dir, local_file), "w") {|f| f << str}
        rescue
          puts "Couldn't download #{link}"
        end
      end
    end
  end
end
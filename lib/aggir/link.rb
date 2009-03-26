require 'uri'
require 'open-uri'
require 'digest/md5'
require 'redis'

module Aggir
  class Link
    LINK_PREFIX = "link"
    LINKS_PREFIX = "links"
    
    attr_accessor :id, :link, :entry_id
    
    REDIS = Redis.new
    
    class << self
      def latest(num = 15)
        ret_links = Array.new
        if REDIS.key?("#{LINKS_PREFIX}:all")
          t_links = REDIS.list_range("#{LINKS_PREFIX}:all", 0, num)
          t_links.each do |l|
            al = Aggir::Link.find(l)
            ret_links << al if al
          end
        end
        ret_links        
      end
      
      def all
        latest(-1)
      end
      
      def find(link_id)
        if REDIS.key?("#{LINK_PREFIX}:#{link_id}")
          id, link, entry_id = REDIS["#{LINK_PREFIX}:#{link_id}"].split("|")
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
      self
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
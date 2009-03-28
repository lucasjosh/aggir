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
        REDIS.key?("#{LINKS_PREFIX}:all") ? Aggir::RedisStorage.latest("#{LINKS_PREFIX}:all", Aggir::Link, 0, num) : []
      end
      
      def all
        Aggir::RedisStorage.all("#{LINKS_PREFIX}:all", Aggir::Link)
      end
      
      def exists?(hashed_link)
        Aggir::RedisStorage.exists?("#{LINK_PREFIX}:#{hashed_link}")
      end
      
      def find(link_id)
        if exists?(link_id)
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
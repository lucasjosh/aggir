require 'httparty'
require 'digest/md5'

module Aggir
  class Delicious
    include HTTParty
    base_uri 'http://feeds.delicious.com'
    format :json
    
    def keywords(url)
      json = self.class.get("/v2/json/urlinfo/#{Digest::MD5.hexdigest(url)}")      
      json.size > 0 ? [json.first['total_posts'],json.first['top_tags']] : nil
    end    
  end
end
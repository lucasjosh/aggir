require 'httparty'
require 'digest/md5'

module Aggir
  class Delicious
    include HTTParty
    base_uri 'http://feeds.delicious.com'
    format :json
    
    def check(url)
      json = self.class.get("/v2/json/urlinfo/#{Digest::MD5.hexdigest(url)}")      
    end    
  end
end
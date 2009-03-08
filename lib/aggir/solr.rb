require 'httparty'

module Aggir
  class Solr
    include HTTParty
    base_uri 'http://localhost:8080/aggir'
    
    
   def update(options = {})
    
   end
   
   def search(options = {})
     self.class.get('/select', options)      
   end
   
   private
   def add_field()
    
   end
  end
end
require 'httparty'

module Aggir
  class Solr
    include HTTParty
    base_uri 'http://localhost:8080/aggir'
    
    
   def update(docs)
    str = "<add>\n"
    docs.each do |doc|
      str << "<doc>\n"
      doc.each {|k,v| str << add_field(k, v)}
      str << "</doc>\n"
    end
    str << "</add>\n"
    self.class.post('/update', {:headers => {"Content-Type" =>  "text/xml"}, :body => str})
    self.class.post('/update', {:headers => {"Content-Type" =>  "text/xml"}, :body => "<commit/>"})
   end
   
   def search(query_params)
     self.class.get('/select', {:query => {:q => query_params, :wt => 'json'}})      
   end
   
   private
   def add_field(key, value)
    "<field name=\"#{key}\">#{value}</field>\n"
   end
  end
end
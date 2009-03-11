require 'rubygems'
require 'sinatra'

require 'lib/aggir'

get '/' do
  @entries = Aggir::Entry.get_latest
  haml :index  
end

get '/search' do
  query = params[:query]
  @entries = Aggir::Entry.search(query)
  haml :result
end

get '/feeds' do 
  @feeds = Aggir::Feed.all
  haml :feed
end


get '/page/:page_num' do
  pn = params[:page_num].to_i
  @entries = Aggir::Entry.get_latest(pn)
  haml :index
end



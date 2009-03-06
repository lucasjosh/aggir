require 'rubygems'
require 'sinatra'

require 'lib/aggir'

get '/' do
  @entries = Aggir::Entry.get_latest
  haml :index  
end

get '/:page_num' do
  pn = params[:page_num].to_i
  @entries = Aggir::Entry.get_latest(pn)
  haml :index
end

get '/feeds' do 
  @feeds = Aggir::Feed.all
  haml :feed
end
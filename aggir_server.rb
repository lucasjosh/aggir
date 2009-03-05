require 'rubygems'
require 'sinatra'

require 'lib/aggir'

get '/' do
  @entries = Aggir::Entry.get_latest
  haml :index
end

get '/feeds' do 
  @feeds = Aggir::Feed.all
  haml :feed
end
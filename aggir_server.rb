require 'rubygems'
require 'sinatra'

require 'lib/aggir'

get '/' do
  @entries = Aggir::Entry.latest
  @page_num = '1'
  haml :index  
end

post '/search' do
  #query, page_num = params[:splat]
  @query = params[:query]
  @page_num = params[:page_num] || '0'
  @entries = Aggir::Entry.search(@query, @page_num)
  haml :result
end

get '/search/:query/:page_num' do
  @query = params[:query]
  @page_num = params[:page_num] || '0'
  @entries = Aggir::Entry.search(@query, @page_num)
  haml :result  
end

get '/feeds' do 
  @feeds = Aggir::Feed.all
  haml :feed
end

get '/feed/:hashed_url' do
  @hashed_url = params[:hashed_url]
  @entries = Aggir::Feed.latest(@hashed_url)
  haml :feed_entries
end


get '/page/:page_num' do
  @page_num = params[:page_num]
  @entries = Aggir::Entry.latest(@page_num.to_i)
  haml :index
end

get '/pdfs' do
  @pdfs = Aggir::Link.latest
  haml :pdfs
end

get '/pdfs/all' do
  @pdfs = Aggir::Link.all
  haml :pdfs
  
end



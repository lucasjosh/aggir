require 'rubygems'
require 'sinatra'

require 'lib/aggir'

get '/' do
  @entries = Aggir::Entry.get_latest
  haml :index
end
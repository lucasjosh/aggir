require 'rubygems'
require 'sequel'
require 'rfeedparser'

db_name = File.join(File.dirname(__FILE__) + '/../db', "aggir.db")
DB = Sequel.sqlite(db_name) unless defined?(DB)
 
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
 
if DB.tables.empty?
  puts "Running migrations...."
  require 'migrations/run'
end
 
 
require File.dirname(__FILE__) + '/aggir/feed' unless defined?(Aggir::Feed)
require File.dirname(__FILE__) + '/aggir/entry' unless defined?(Aggir::Entry)
require File.dirname(__FILE__) + '/aggir/link' unless defined?(Aggir::Link)
 
module Aggir
  VERSION = '0.0.1'
end

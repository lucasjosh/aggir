require 'rubygems'
require 'sequel'

db_name = File.join(File.dirname(__FILE__) + '/../db', "aggir.db")
DB = Sequel.sqlite(db_name)
 
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
 
if DB.tables.empty?
  puts "Running migrations...."
  require 'migrations/run'
end
 
#require 'aggir/entry'
 
module Aggir
  VERSION = '0.0.1'
end
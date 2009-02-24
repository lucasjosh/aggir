require 'rubygems'
require 'sequel'
require 'test/unit'
require 'shoulda'

DB = Sequel.sqlite

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'aggir'

 
def db_setup
  
  if DB.tables.empty?
    puts "Running migrations...."
    $:.unshift(File.dirname(__FILE__) + '/../lib')
    require 'migrations/run'
  end  
end

def db_clean_up
end


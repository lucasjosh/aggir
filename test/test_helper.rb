require 'rubygems'
require 'sequel'
require 'test/unit'
require 'shoulda'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'aggir'

db_name = File.join(File.dirname(__FILE__) + '/../db', "aggir_test.db")
DB = Sequel.sqlite

# 
def db_setup
  
  if DB.tables.empty?
    puts "Running migrations...."
    $:.unshift(File.dirname(__FILE__) + '/../lib')
    require 'migrations/run'
  end  
end

def db_clean_up
end


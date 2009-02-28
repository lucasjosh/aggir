require 'rubygems'
require 'sequel'
require 'test/unit'
require 'shoulda'

require 'flexmock/test_unit'

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
  DB.disconnect
end

def setup_feed_data
  str = open(File.join(File.dirname(__FILE__),'data', 'blog.xml')).read
  data = FeedParser.parse(str)
  flexmock(FeedParser).should_receive(:parse).and_return(data)
end


require 'rubygems'
require 'redis'

require 'test/unit'
require 'shoulda'

require 'flexmock/test_unit'

require 'digest/md5'


FEED_ID_KEY = "test_global:feed_id" 
FEED_PREFIX = "test_feed" 
ENTRIES_PREFIX = "test_entries" 

ENTRY_ID_KEY = "test_global:entry_id" 
ENTRY_PREFIX = "test_entry"

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'aggir'


 
def redis_setup
  @r = Redis.new
  all_keys = @r.keys("test_*")
  all_keys.each do |key|
    puts "Deleting #{key}"
    @r.delete(key)
  end
end

def setup_feed_data
  str = open(File.join(File.dirname(__FILE__),'data', 'blog.xml')).read
  data = FeedParser.parse(str)
  flexmock(FeedParser).should_receive(:parse).and_return(data)
end

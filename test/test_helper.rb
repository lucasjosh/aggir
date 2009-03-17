require 'rubygems'
require 'redis'

require 'test/unit'
require 'shoulda'

require 'flexmock/test_unit'

require 'digest/md5'


$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'aggir'

 
def redis_setup
  @r = Redis.new
end

def setup_feed_data
  str = open(File.join(File.dirname(__FILE__),'data', 'blog.xml')).read
  data = FeedParser.parse(str)
  flexmock(FeedParser).should_receive(:parse).and_return(data)
end


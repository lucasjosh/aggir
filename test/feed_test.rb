require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class FeedTest < Test::Unit::TestCase

  context "Basic Aggir::Feed" do
    
    setup { db_setup }

    should "be a Sequel::Model class" do
      assert_equal Aggir::Feed.superclass, Sequel::Model
    end
    
    should "create a new Feed when not in DB" do
      feed = Aggir::Feed.find_by_feed_url("http://www.lucasjosh.com/blog/feed/")
      assert_nil feed
      feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
      assert_not_nil feed
    end
    
    should "save correct data from Feed" do
      feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
      assert_not_nil feed
      assert_equal "lucasjosh.com", feed.title
      assert_equal "http://lucasjosh.com/blog", feed.url
      assert_equal "http://www.lucasjosh.com/blog/feed/", feed.feed_url
    end
    
    teardown { db_clean_up }
  end


end
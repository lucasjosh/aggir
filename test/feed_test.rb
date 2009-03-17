require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class FeedTest < Test::Unit::TestCase

  context "Basic Aggir::Feed" do
    
    setup { redis_setup }
    
    should "have the correct initial id from Redis" do
      @r.delete("global:feed_id")
      assert_equal 1001, Aggir::Feed.get_next_id
      assert_equal 1002, Aggir::Feed.get_next_id
      @r.delete("global:feed_id")
    end

    should "not be found when not in Redis" do
      setup_feed_data
      assert_nil Aggir::Feed.find_by_feed_url("http://www.lucasjosh.com/blog/feed/")      
    end
    
    should "create a new Feed when not in Redis" do
      setup_feed_data
      feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
      assert_not_nil feed
      assert_equal 1001, feed.id
      assert_equal "lucasjosh.com", feed.title
      assert_equal "http://lucasjosh.com/blog", feed.url
      assert_equal "http://www.lucasjosh.com/blog/feed/", feed.feed_url
      hash_url = Digest::MD5.hexdigest(feed.feed_url)
      @r.delete("feed:#{hash_url}")
      @r.delete("feed:#{hash_url}:id")
      @r.delete("global:feed_id")      
    end    
    
  end
  
  context "Aggir::Feed" do
    # setup { db_setup }
    # 
    # should "not add entries twice" do
    #   setup_feed_data
    #   feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
    #   feed.update_entries
    #   assert_equal 10, feed.entries.size
    #   feed.update_entries
    #   assert_equal 10, feed.entries.size
    # end
  end


end
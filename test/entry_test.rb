require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class EntryTest < Test::Unit::TestCase

  context "Aggir::Entry" do
    setup { redis_setup }
    
    should "save correct data" do
      setup_feed_data
      feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
      feed.update_entries
      assert_equal "EarthLink, Short Term Profit but Long Term?", feed.entries.first.title
    end
    
    should "not insert the same entry twice" do
      setup_feed_data
      feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")      
      feed.update_entries      
      entry = Aggir::Entry.find("http://lucasjosh.com/blog/2009/02/06/earthlink-short-term-profit-but-long-term/")
      #Fri Feb 06 09:17:52 -0800 2009
      require 'parsedate'
      res = ParseDate.parsedate("Thu Feb 05 09:17:52 -0800 2009")
      feb_05 = Time.local(*res)
      assert entry.need_update?(Time.now)
      assert_equal false, entry.need_update?(feb_05)
    end    
    
  end  
end

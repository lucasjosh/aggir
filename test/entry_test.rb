require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class EntryTest < Test::Unit::TestCase

  context "Basic Aggir::Entry" do
    setup { db_setup }
    
    should "be a Sequel::Model class" do
      assert_equal Aggir::Entry.superclass, Sequel::Model
    end
        
    should "be associated with a saved feed" do
      feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
      e = Aggir::Entry.new
      e.feed = feed
      e.save
      
      assert_equal "lucasjosh.com", e.feed.title
    end
  end
  
  context "Aggir::Entry" do
    setup { db_setup }
    
    should "save correct data" do
      setup_feed_data
      feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
      feed.update_entries
      assert_equal "EarthLink, Short Term Profit but Long Term?", feed.entries.first.title
    end
    
  end
  
  context "Aggir::Entry" do
    setup { db_setup }
    
    should "find by a guid" do
      setup_feed_data
      assert_nil Aggir::Entry.find_guid("xxxxx")
      feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
      feed.update_entries
      assert_equal "http://lucasjosh.com/blog/?p=260", feed.entries.first.guid
      entry = Aggir::Entry.find_guid(feed.entries.first.guid)
      assert_equal "EarthLink, Short Term Profit but Long Term?", entry.title
    end
    
    should "not insert the same entry twice" do
      setup_feed_data
      entry = Aggir::Entry.find_guid("http://lucasjosh.com/blog/?p=260")
      #Fri Feb 06 09:17:52 -0800 2009
      require 'parsedate'
      res = ParseDate.parsedate("Thu Feb 05 09:17:52 -0800 2009")
      feb_05 = Time.local(*res)
      assert entry.need_update?(Time.now)
      assert_equal false, entry.need_update?(feb_05)
    end
    
  end

end

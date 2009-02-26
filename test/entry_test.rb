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

end

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
    
    should "save correct data"
  end


end
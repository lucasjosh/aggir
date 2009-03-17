require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class EntryTest < Test::Unit::TestCase

  context "Basic Aggir::Entry" do
    setup { redis_setup }
    
        
  context "Aggir::Entry" do
    setup { redis_setup }
    
    should "save correct data" do
      setup_feed_data
      feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
      feed.update_entries
      assert_equal "EarthLink, Short Term Profit but Long Term?", feed.entries.first.title
      hash_url = Digest::MD5.hexdigest(feed.feed_url)
      feed.entries.each {|entry| 
        @r.delete("entry:#{entry.hashed_guid}")
        @r.delete("entry:#{entry.hashed_guid}:id")
      }
      @r.delete("feed:#{hash_url}")
      @r.delete("feed:#{hash_url}:id")
      @r.delete("global:feed_id")      
      @r.delete("global:entry_id")
      
    end
    
  end
  
  context "Aggir::Entry" do
    setup { redis_setup }
    
    should "find by a hashed guid" do
      # setup_feed_data
      # feed = Aggir::Feed.create_or_update("http://www.lucasjosh.com/blog/feed/")
      # feed.update_entries
      # assert_equal "87c2dbb4400cc0009d0425118ee0bb95", feed.entries.first.hashed_guid
      # entry = Aggir::Entry.find_hashed_guid(feed.entries.first.link)
      # assert_equal "EarthLink, Short Term Profit but Long Term?", entry.title
    end
    
    should "not insert the same entry twice" do
      # setup_feed_data
      # entry = Aggir::Entry.find_guid("http://lucasjosh.com/blog/?p=260")
      # #Fri Feb 06 09:17:52 -0800 2009
      # require 'parsedate'
      # res = ParseDate.parsedate("Thu Feb 05 09:17:52 -0800 2009")
      # feb_05 = Time.local(*res)
      # assert entry.need_update?(Time.now)
      # assert_equal false, entry.need_update?(feb_05)
    end
    
  end

end

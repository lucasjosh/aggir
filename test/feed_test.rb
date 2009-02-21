require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class FeedTest < Test::Unit::TestCase

  context "Basic Aggir::Feed" do
    should "be a Sequel::Model class" do
      assert_equal Aggir::Feed.superclass, Sequel::Model
    end
  end


end
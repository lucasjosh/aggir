require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class LinkTest < Test::Unit::TestCase

  context "Basic Aggir::Link" do
    
    setup { db_setup }

    should "be a Sequel::Model class" do
      assert_equal Aggir::Link.superclass, Sequel::Model
    end
  end
end
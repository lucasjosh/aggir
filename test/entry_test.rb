require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class EntryTest < Test::Unit::TestCase

  context "Basic Aggir::Entry" do
    should "be a Sequel::Model class" do
      assert_equal Aggir::Entry.superclass, Sequel::Model
    end
  end


end
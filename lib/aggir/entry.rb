module Aggir
  class Entry < Sequel::Model
    many_to_one :feed, :class => Aggir::Feed
  end
end
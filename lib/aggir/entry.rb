module Aggir
  class Entry < Sequel::Model
    many_to_one :feed, :class => "Aggir::Feed"
    
    class << self
      def find_guid(guid)
        Entry.find :guid => guid
      end
    end
    
    def need_update?(publish_time)
      published < publish_time
    end
    
  end
end
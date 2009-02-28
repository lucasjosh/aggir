module Aggir
  class Link < Sequel::Model
    many_to_one :entry, :class => "Aggir::Entry"
    
    class << self
      def get_latest(num = 10)
        Link.reverse_order(:id).limit(num)
      end
    end
  end
end
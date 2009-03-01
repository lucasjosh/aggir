require 'uri'
require 'open-uri'

module Aggir
  class Link < Sequel::Model
    many_to_one :entry, :class => "Aggir::Entry"
    
    class << self
      def get_latest(num = 10)
        Link.reverse_order(:id).limit(num)
      end
    end
    
    def download(download_dir)
      url = URI.parse(link)
      local_file = url.path.split("/").last
      unless File.exists?(File.join(download_dir, local_file))
        str = open(link).read      
        open(File.join(download_dir, local_file), "w") {|f| f << str}
      end
    end
  end
end
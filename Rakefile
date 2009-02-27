require(File.join(File.dirname(__FILE__), 'lib', 'aggir'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'


task :default => ["update:feeds"]
#http://www.searchenginecaffe.com/feeds/posts/default on hold

URLS = %w(http://feeds2.feedburner.com/GeekingWithGreg
http://feeds.feedburner.com/daniel-lemire/atom
http://thenoisychannel.com/feed/
http://irgupf.com/feed/
http://windowoffice.tumblr.com/rss
http://feeds.feedburner.com/stanfordinfoblog
http://blogs.sun.com/searchguy/feed/entries/atom
http://scienceblogs.com/goodmath/index.xml
http://musicmachinery.com/feed/)

namespace :update do
  desc "Update feeds..."
  task :feeds do
    URLS.each do |url|
      f = Aggir::Feed.create_or_update(url)
      unless f.nil?
        f.update_entries
      else
        puts "URL: #{url} came back as nil!"
      end
    end
  end
end

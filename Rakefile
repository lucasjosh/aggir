require(File.join(File.dirname(__FILE__), 'lib', 'aggir'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'


task :default => ["update:feeds"]

URLS = %w(http://feeds2.feedburner.com/GeekingWithGreg
http://feeds.feedburner.com/daniel-lemire/atom
http://www.searchenginecaffe.com/feeds/posts/default
http://thenoisychannel.com/feed/
http://irgupf.com/feed/
http://windowoffice.tumblr.com/rss
http://feeds.feedburner.com/stanfordinfoblog
http://blogs.sun.com/searchguy/feed/entries/atom
http://scienceblogs.com/goodmath/index.xml
http://musicmachinery.com/feed/)

namespace :feeds do
  desc "Update feeds..."
  task :update do
    Aggir::Feed.all.each do |f|
      f.update_entries
    end
  end
  
  task :add do
    url = ENV['url']
    raise StandardError.new("You must give a URL...") if url.blank?
    Aggir::Feed.create_or_update(url)
  end

  desc "Creating default feeds..."
  task :create do
    URLS.each do |url|
      f = Aggir::Feed.create_or_update(url)
      unless f.nil?
        f.update_entries
      else
        puts "URL: #{url} came back as nil!"
      end
    end    
  end
  
  desc "Grab latest 15 headlines..."
  task :latest do 
    latest = Aggir::Entry.get_latest(15)
    latest.each do |l|
      puts "#{l.feed.title} - #{l.title}"
    end   
  end
  
end

namespace :pdf do
  
  desc "Show latest PDFs"
  task :latest do
    pdfs = Aggir::Link.get_latest
    pdfs.each do |pdf|
      puts "#{pdf.entry.feed.title}: #{pdf.entry.title} - #{pdf.link}"
    end
  end
  
  desc "Download latest PDFs"
  task :download do
    download_dir = File.join(File.dirname(__FILE__), 'downloads')
    FileUtils.mkdir(download_dir) unless File.exists?(download_dir)    
    pdfs = Aggir::Link.get_latest
    pdfs.each do |pdf|
      puts "Downloading #{pdf.link}..."
      pdf.download(download_dir)
    end
  end
end

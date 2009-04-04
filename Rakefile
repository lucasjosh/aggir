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
http://musicmachinery.com/feed/
http://blogs.sun.com/searchguy/feed/entries/atom)

namespace :feeds do
  desc "Update feeds..."
  task :update do
    Aggir::Feed.all.each do |f|
      f.update_entries
    end
    Aggir::Feed.sort_entries
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
    Aggir::Feed.sort_entries   
  end
  
  desc "Grab latest 15 headlines..."
  task :latest do 
    latest = Aggir::Entry.latest
    latest.each do |l|
      puts "#{l.feed.title} - #{l.title}"
    end   
  end
  
  desc "Sending all entries to Solr..."
  task :update_search do
    require 'cgi'
    latest = Aggir::Entry.all
    puts "Sending #{latest.size} entries to Solr..."
    #posts = []
    latest.each do |l|
      posts = []
      stripped_content = l.content.gsub(/<\/?[^>]*>/, "")
      stripped_content = CGI.escapeHTML(stripped_content)
      keywords = l.find_keywords
      posts << {:id => l.hashed_guid, :title => l.title, 
                :post => stripped_content, :link => l.link, :keywords => keywords.join(" ")}
      Aggir::Solr.new.update(posts)
    end
    #Aggir::Solr.new.update(posts)
  end
  
  desc "Find Entry keywords from Delicious"
  task :find_keywords do
    Aggir::Entry.latest.each do |e|
      puts e.find_keywords.inspect
    end
  end
end

namespace :pdf do
  
  desc "Download All PDFs"
  task :download_all do
    download_dir = File.join(File.dirname(__FILE__), 'downloads')
    FileUtils.mkdir(download_dir) unless File.exists?(download_dir)    
    pdfs = Aggir::Link.all
    pdfs.each do |pdf|
      puts "Downloading #{pdf.link}..."
      pdf.download(download_dir)
    end
  end
  
  desc "Download Latest PDFs" 
  task :download do
    download_dir = File.join(File.dirname(__FILE__), 'downloads')
    FileUtils.mkdir(download_dir) unless File.exists?(download_dir)    
    pdfs = Aggir::Link.latest
    pdfs.each do |pdf|
      puts "Downloading #{pdf.link}..."
      pdf.download(download_dir)
    end    
  end
end


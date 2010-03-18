require(File.join(File.dirname(__FILE__), 'lib', 'aggir'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'


task :default => ["feeds:update"]

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
    data_dir = File.join(File.dirname(__FILE__), 'solr_config', 'solr', 'data')
    FileUtils.mkdir(data_dir) unless File.exists?(data_dir)    

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
  
  desc "Show Last 10 Feeds"
  task :latest_feeds do
    Aggir::Feed.most_recent.each do |f|
      puts "#{f.title} - #{f.entries.size} Posts"
    end
  end
  
  desc "Show Number of posts for all feeds"
  task :all_feeds do
    Aggir::Feed.all.each do |f|
      puts "#{f.title} - #{f.entries.size} Posts"
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

namespace :tomcat do
  desc "process and install the aggir.xml file"
  task "context" do
    raise "missing CATALINA_HOME" unless tomcat_home = ENV['CATALINA_HOME']
    path = "#{tomcat_home}/conf/Catalina/localhost/aggir.xml"

    context = File.read("solr_config/aggir.xml")
    here = File.expand_path File.dirname(__FILE__)
    context.gsub!("%SOLR_DIR%", "#{here}/solr_config")
    File.open(path, "w") { |f| f.print context }
  end

  desc "run Tomcat's startup.sh"
  task "start" do
    raise "missing CATALINA_HOME" unless tomcat_home = ENV['CATALINA_HOME']
    puts exe = "#{tomcat_home}/bin/startup.sh"
    Dir.chdir("solr_config/solr") do
      system exe
    end
  end

  desc "run Tomcat's shutdown.sh"
  task "stop" do
    raise "missing CATALINA_HOME" unless tomcat_home = ENV['CATALINA_HOME']
    puts exe = "#{tomcat_home}/bin/shutdown.sh"
    Dir.chdir("solr_config/solr") do
      system exe
    end
  end
end


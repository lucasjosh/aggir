module Aggir
  class FeedsMigrations < Sequel::Migration
    def up
      
      create_table :feeds do
        primary_key :id
        varchar :title
        varchar :url
        varchar :feed_url
      end
    end
 
    def down
      drop_table :feeds
      drop_table :entries
    end
  end
  
  class EntriesMigrations < Sequel::Migration
    def up
      create_table :entries do
        primary_key :id
        varchar :title
        varchar :link
        varchar :name
        varchar :content
        varchar :summary
        datetime :published
        datetime :created
        integer :feed_id
        varchar :guid
        varchar :hashed_guid
      end      
      
    end
  end
  
  class LinksMigrations < Sequel::Migration
    def up
      create_table :links do
        primary_key :id
        varchar :link
        integer :entry_id
      end
    end
  end
end

 
Aggir::FeedsMigrations.apply(DB, :up)
Aggir::EntriesMigrations.apply(DB, :up)
Aggir::LinksMigrations.apply(DB, :up)


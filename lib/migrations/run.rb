module Aggir
  class Migrations < Sequel::Migration
    def up
      create_table :entries do
        primary_key :id
        varchar     :title
        varchar     :link
        varchar     :name
        varchar     :content
        varchar     :summary
        datetime    :published
        datetime    :created
        
      end
    end
 
    def down
      drop_table :entries
    end
  end
end
 
Aggir::Migrations.apply(DB, :up)

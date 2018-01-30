# This migration comes from acts_as_taggable_on_engine (originally 1)
class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    
    if not ActiveRecord::Base.connection.table_exists? 'tags' then

      create_table :tags do |t|
        t.string :name
      end
    end
    if not ActiveRecord::Base.connection.table_exists? 'taggings' then
    
      create_table :taggings do |t|
        t.references :tag

        # You should make sure that the column created is
        # long enough to store the required class names.
        t.references :taggable, polymorphic: true
        t.references :tagger, polymorphic: true

        # Limit is created to prevent MySQL error on index
        # length for MyISAM table type: http://bit.ly/vgW2Ql
        t.string :context, limit: 128

        t.datetime :created_at
      end

      add_index :taggings, :tag_id
      add_index :taggings, [:taggable_id, :taggable_type, :context]
    end
  end

  def self.down
    if ActiveRecord::Base.connection.table_exists? 'taggings' then

      drop_table :taggings
    end
                
    if ActiveRecord::Base.connection.table_exists? 'tags' then

      drop_table :tags
    end
  end
end

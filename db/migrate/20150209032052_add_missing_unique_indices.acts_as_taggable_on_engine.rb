# This migration comes from acts_as_taggable_on_engine (originally 2)
class AddMissingUniqueIndices < ActiveRecord::Migration
  def self.up
    if not ActiveRecord::Base.connection.index_exists?(:tags, :name)
      add_index :tags, :name, unique: true
    end
    
    if ActiveRecord::Base.connection.index_exists?(:taggings, :tag_id)
      remove_index :taggings, :tag_id
    end
    
    if ActiveRecord::Base.connection.index_exists?(:taggings, :tag_id)
      remove_index :taggings, [:taggable_id, :taggable_type, :context]
    end
                                
    if ActiveRecord::Base.connection.index_name_exists?(:taggings,'taggings_idx',"").blank? 
      add_index :taggings, [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type], unique: true, name: 'taggings_idx'
    end
  end

  def self.down
    if ActiveRecord::Base.connection.index_exists?(:tags, :name)
      remove_index :tags, :name
    end
    
    
    if not ActiveRecord::Base.connection.index_name_exists?(:taggings,'taggings_idx',"").blank?
      remove_index :taggings, name: 'taggings_idx'
    end
    
    
    if not ActiveRecord::Base.connection.index_exists?(:taggings, :tag_id)
      add_index :taggings, :tag_id
    end
    
    
    if not ActiveRecord::Base.connection.index_exists?(:taggings, [:taggable_id, :taggable_type, :context])
      add_index :taggings, [:taggable_id, :taggable_type, :context]
    end
  end
end

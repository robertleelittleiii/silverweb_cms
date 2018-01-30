# This migration comes from acts_as_taggable_on_engine (originally 4)
class AddMissingTaggableIndex < ActiveRecord::Migration
  def self.up
    if not ActiveRecord::Base.connection.index_exists?(:taggings, [:taggable_id, :taggable_type, :context])
      add_index :taggings, [:taggable_id, :taggable_type, :context]
    end
  end

  def self.down
    if  ActiveRecord::Base.connection.index_exists?(:taggings, [:taggable_id, :taggable_type, :context])
      remove_index :taggings, [:taggable_id, :taggable_type, :context]
    end
  end
end

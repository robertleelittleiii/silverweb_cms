# This migration comes from acts_as_taggable_on_engine (originally 3)
class AddTaggingsCounterCacheToTags < ActiveRecord::Migration
  def self.up
    if !ActiveRecord::Base.connection.column_exists?(:tags, :taggings_count) then
      add_column :tags, :taggings_count, :integer, default: 0
    end
   
    ActsAsTaggableOn::Tag.reset_column_information
    ActsAsTaggableOn::Tag.find_each do |tag|
      ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
    end
  end

  def self.down
    if ActiveRecord::Base.connection.table_exists? :tags then

      if ActiveRecord::Base.connection.column_exists?(:tags, :taggings_count)
        remove_column :tags, :taggings_count
      end
    end
  end
end

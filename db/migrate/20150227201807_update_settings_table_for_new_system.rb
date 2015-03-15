class UpdateSettingsTableForNewSystem < ActiveRecord::Migration
  def self.up
    rename_column :settings, :target_type,  :thing_type
    rename_column :settings, :target_id, :thing_id

  end

  def self.down
    rename_column :settings,  :thing_type, :target_type
    rename_column :settings, :thing_id, :target_id
  end
end

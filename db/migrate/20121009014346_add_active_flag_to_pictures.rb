class AddActiveFlagToPictures < ActiveRecord::Migration[5.0]
  def self.up
    add_column :pictures, :active_flag, :boolean
  end

  def self.down
    remove_column :pictures, :active_flag
  end
end

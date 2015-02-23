class AddHasImageToMenus < ActiveRecord::Migration
  def self.up
    add_column :menus, :has_image, :boolean
  end

  def self.down
    remove_column :menus, :has_image
  end
end

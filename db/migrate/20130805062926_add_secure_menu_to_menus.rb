class AddSecureMenuToMenus < ActiveRecord::Migration
  def self.up
    add_column :menus, :secure_menu, :boolean
  end

  def self.down
    remove_column :menus, :secure_menu
  end
end

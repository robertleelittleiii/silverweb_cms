class AddSecureMenuToMenus < ActiveRecord::Migration[5.0]
  def self.up
    add_column :menus, :secure_menu, :boolean
  end

  def self.down
    remove_column :menus, :secure_menu
  end
end

class AddMenuActiveToMenus < ActiveRecord::Migration
  def self.up
    add_column :menus, :menu_active, :boolean
  end

  def self.down
    remove_column :menus, :menu_active
  end
end

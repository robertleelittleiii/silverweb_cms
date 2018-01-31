class AddMenuActiveToMenus < ActiveRecord::Migration[5.0]
  def self.up
    add_column :menus, :menu_active, :boolean
  end

  def self.down
    remove_column :menus, :menu_active
  end
end

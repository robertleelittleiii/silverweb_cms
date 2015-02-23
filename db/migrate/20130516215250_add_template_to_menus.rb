class AddTemplateToMenus < ActiveRecord::Migration
  def self.up
    add_column :menus, :template, :string
  end

  def self.down
    remove_column :menus, :template
  end
end

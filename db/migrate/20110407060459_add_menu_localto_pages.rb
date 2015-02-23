class AddMenuLocaltoPages < ActiveRecord::Migration
  def self.up
        add_column :pages, :in_menu, :boolean
        add_column :pages, :menu_local, :string
  end

  def self.down
        remove_column :pages, :in_menu
        remove_column :pages, :menu_local
  end
end

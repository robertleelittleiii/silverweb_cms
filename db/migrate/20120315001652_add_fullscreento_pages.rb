class AddFullscreentoPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :full_screen, :boolean
  end

  def self.down
    remove_column :pages, :full_screen
  end
end

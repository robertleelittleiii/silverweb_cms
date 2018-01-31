class AddFullscreentoPages < ActiveRecord::Migration[5.0]
  def self.up
    add_column :pages, :full_screen, :boolean
  end

  def self.down
    remove_column :pages, :full_screen
  end
end

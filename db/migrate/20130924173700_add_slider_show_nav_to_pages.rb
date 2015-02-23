class AddSliderShowNavToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :slider_show_nav, :boolean
  end

  def self.down
    remove_column :pages, :slider_show_nav
  end
end

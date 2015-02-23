class AddHassliderToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :has_slider, :boolean
  end

  def self.down
    remove_column :pages, :has_slider
  end
end

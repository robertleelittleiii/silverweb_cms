class AddHassliderToPages < ActiveRecord::Migration[5.0]
  def self.up
    add_column :pages, :has_slider, :boolean
  end

  def self.down
    remove_column :pages, :has_slider
  end
end

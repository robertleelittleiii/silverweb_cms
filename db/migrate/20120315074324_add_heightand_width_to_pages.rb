class AddHeightandWidthToPages < ActiveRecord::Migration[5.0]
  def self.up
    add_column :pages, :slider_height, :integer
    add_column :pages, :slider_width, :integer
  end

  def self.down
    remove_column :pages, :slider_width
    remove_column :pages, :slider_height
  end
end

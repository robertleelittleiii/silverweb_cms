class AddStyleToPages < ActiveRecord::Migration[5.0]
  def self.up
    add_column :pages, :page_style, :string
  end

  def self.down
    remove_column :pages, :page_style
  end
end

class UpdateMetaColumnsForPages < ActiveRecord::Migration
  def self.up
    change_column :pages, :meta_description, :text
    change_column :pages, :meta_keywords, :text
  end

  def self.down
    change_column :pages, :meta_description, :string
    change_column :pages, :meta_keywords, :string
  end
end

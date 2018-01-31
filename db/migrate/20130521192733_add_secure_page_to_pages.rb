class AddSecurePageToPages < ActiveRecord::Migration[5.0]
  def self.up
    add_column :pages, :secure_page, :boolean
  end

  def self.down
    remove_column :pages, :secure_page
  end
end

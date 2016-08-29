class AddPopupLinkToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :pop_up_page_link, :string
  end

  def self.down
    remove_column :pages, :pop_up_page_link
  end
end

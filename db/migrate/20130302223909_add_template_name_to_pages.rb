class AddTemplateNameToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :template_name, :string
  end

  def self.down
    remove_column :pages, :template_name
  end
end

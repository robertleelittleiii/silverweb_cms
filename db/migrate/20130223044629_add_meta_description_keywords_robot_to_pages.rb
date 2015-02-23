class AddMetaDescriptionKeywordsRobotToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :meta_description, :string
    add_column :pages, :meta_keywords, :string
    add_column :pages, :meta_robot, :string
  end

  def self.down
    remove_column :pages, :meta_robot
    remove_column :pages, :meta_keywords
    remove_column :pages, :meta_description
  end
end

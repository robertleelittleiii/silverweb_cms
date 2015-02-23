class CreatePageTemplates < ActiveRecord::Migration
  def self.up
    create_table :page_templates do |t|
      t.string :title
      t.string :description
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :page_templates
  end
end

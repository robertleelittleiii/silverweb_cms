class CreatePageTemplates < ActiveRecord::Migration
  def self.up
    if not ActiveRecord::Base.connection.table_exists? 'page_templates' then
      create_table :page_templates do |t|
        t.string :title
        t.string :description
        t.text :body

        t.timestamps
      end
    end
  end

  def self.down
    if ActiveRecord::Base.connection.table_exists? 'page_templates' then
      drop_table :page_templates
    end
  end
end

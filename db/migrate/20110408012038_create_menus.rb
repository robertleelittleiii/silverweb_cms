class CreateMenus < ActiveRecord::Migration[5.0]
  def self.up
    create_table :menus do |t|
      t.string :name
      t.integer :page_id
      t.integer :parent_id
      t.boolean :has_submenu
      t.integer :m_order
      t.string :m_type
      t.string :rawhtml
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :menus
  end
end

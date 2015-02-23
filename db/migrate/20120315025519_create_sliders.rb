class CreateSliders < ActiveRecord::Migration
  def self.up
    create_table :sliders do |t|
      t.integer :page_id
      t.integer :slider_order
      t.string :slider_name
      t.boolean :slider_active
      t.integer :slider_type
      t.text :slider_content

      t.timestamps
    end
    
    role_admin =  Role.find_by_name('Admin')
    role_cust =  Role.find_by_name('Customer')
    role_siteowner =  Role.find_by_name('Site Owner')


    right = Right.create name: "*Access to all slider actions", controller: "sliders", action: "*"
    role_admin.rights << right
    role_siteowner.rights << right

    role_siteowner.save
    role_cust.save
    role_admin.save
    
  end

  def self.down
    drop_table :sliders
    
    right = Right.find_by_name( "*Access to all slider actions")
    right.destroy  rescue puts("slider right not found.")
  end
end

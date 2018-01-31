class UpdatePermissionsOnPageTemplates < ActiveRecord::Migration[5.0]
  def self.up
    #assign them to Admin role.
    role_admin =  Role.find_by_name('Admin')
    role_cust =  Role.find_by_name('Customer')
    role_siteowner =  Role.find_by_name('Site Owner')


    right = Right.create name: "*Access to all page template actions", controller: "page_templates", action: "*"
    role_admin.rights << right
    role_siteowner.rights << right
    role_cust.rights << right
    
    role_siteowner.save
    role_cust.save
    role_admin.save 
  end

  def self.down
    #Destroy all rights    
    right = Right.find_by_name( "*Access to all page template actions")
    right.destroy  rescue puts("order right not found.")
    
  end
end

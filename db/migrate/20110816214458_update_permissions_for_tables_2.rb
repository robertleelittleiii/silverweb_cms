class UpdatePermissionsForTables2 < ActiveRecord::Migration[5.0]
  def self.up
    
		#Admin role name should be "Admin" for convenience
    #role_sales = Role.new
		#role_sales.name = "Sales"
		#role_sales.save
    #
    #Create all of the rights for all existing controllers for the admin
    #assign them to Admin role.
    role_admin =  Role.find_by_name('Admin')
    role_cust =  Role.find_by_name('Customer')
    role_siteowner =  Role.find_by_name('Site Owner')


    right = Right.create name: "*Access to all menu actions", controller: "menus", action: "*"
    role_admin.rights << right
    role_siteowner.rights << right
    
    right = Right.create name: "*Access to all page actions", controller: "pages", action: "*"
    role_admin.rights << right
    role_siteowner.rights << right
    
   
    right = Right.create name: "*Access to all attachment actions", controller: "attachments", action: "*"
    role_admin.rights << right
    role_siteowner.rights << right
    
   
    right = Right.create name: "*Access to all user attributes actions", controller: "user_attributes", action: "*"
    role_admin.rights << right
    role_cust.rights << right
    role_siteowner.rights << right
    
    right = Right.find_by_name("*Access to all admin actions")

    
    right = Right.find_by_name("*Access to all rights actions")

    right = Right.find_by_name("*Access to all roles actions")

    right = Right.find_by_name("*Access to all user actions")

    right = Right.find_by_name("*Access to all login actions")
    #    role_manager.rights << right
    #    role_receiving.rights << right
    #    role_sales.rights << right
    #   role_shipping.rights << right
    
   
    role_siteowner.save
    role_cust.save
    role_admin.save 
    
  end

  def self.down
    #Get Admin User
    admin_user =  User.find_by_name('Admin@one.com')

    #Get Admin Role


    # Clear Admin user roles
    # NOT NEEDED
    #    admin_user.roles << []
    #    admin_user.save

    #Destroy Admin User - can't delete last user.
    #    admin_user.destroy

    # Clear Admin role rights
    # NOT NEEDED
    #   admin_role.rights = []

    #Destroy Admin Role

    #Destroy all rights    
    right = Right.find_by_name( "*Access to all menu actions")
    right.destroy  rescue puts("menu right not found.")
    right = Right.find_by_name( "*Access to all attachment actions")
    right.destroy  rescue puts("attachment right not found.")
    right = Right.find_by_name( "*Access to all page actions")
    right.destroy  rescue puts("page right not found.")
    right = Right.find_by_name( "*Access to all user attributes actions")
    right.destroy  rescue puts("user attributes right not found.")
  end
end

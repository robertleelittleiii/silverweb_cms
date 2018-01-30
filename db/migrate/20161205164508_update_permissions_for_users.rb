class UpdatePermissionsForUsers < ActiveRecord::Migration
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


    right = Right.create name: "*Access to user set time zone", controller: "users", action: "set_time_zone"
    role_admin.rights << right
    role_siteowner.rights << right
    role_cust.rights << right
   
   
    role_siteowner.save
    role_cust.save
    role_admin.save 
    
  end

  def self.down
    #Destroy all rights    
    right = Right.find_by_name( "*Access to user set time zone")
    right.destroy  rescue puts("set_time_zone right not found.")
  end
end

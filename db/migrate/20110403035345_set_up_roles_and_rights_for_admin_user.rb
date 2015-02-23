class SetUpRolesAndRightsForAdminUser < ActiveRecord::Migration
 def self.up
    #Create the Admin user.


    adminuser = User.create(name: 'Admin@one.com', password: 'password', password_confirmation: 'password')

    adminuserattributes = UserAttribute.create(first_name: "Admin", last_name: "User")
    adminuser.user_attribute = adminuserattributes
    adminuser.save

    #Create the Admin Role (so we can login to system)



		#Admin role name should be "Admin" for convenience
    role = Role.new
		role.name = "Admin"
		role.save

    role_cust = Role.new
    role_cust.name = "Customer"
    role_cust.save

    role_siteowner = Role.new
    role_siteowner.name = "Site Owner"
    role_siteowner.save

    #Create all of the rights for all existing controllers for the admin
    #assign them to Admin role.

    right = Right.create name: "*Access to all admin actions", controller: "admin", action: "*"
    role_siteowner.rights << right
    role.rights << right
    role_cust.rights << right

    right = Right.create name: "*Access to all pages actions", controller: "pages", action: "*"
    role.rights << right
    role_siteowner.rights << right

    right = Right.create name: "*Access to all rights actions", controller: "rights", action: "*"
    role.rights << right

    right = Right.create name: "*Access to all roles actions", controller: "roles", action: "*"
    role.rights << right

    right = Right.create name: "*Access to all user actions", controller: "users", action: "*"
    role.rights << right

    right = Right.create name: "*Access to all login actions", controller: "login", action: "*"
    role.rights << right
    role_siteowner.rights << right
    role_cust.rights << right

 
    role_siteowner.save
    role_cust.save
    role.save

    #Be sure to change these settings for your initial admin user
    admin_user =  User.find_by_name('Admin@one.com')
		admin_role = Role.find_by_name("Admin")
		admin_user.roles << admin_role
		admin_user.save
  end

  def self.down
    #Get Admin User
    admin_user =  User.find_by_name('Admin@one.com')

    #Get Admin Role
		admin_role = Role.find_by_name("Admin")
    siteowner_role = Role.find_by_name("Site Owner")
    customer_role = Role.find_by_name("Customer")

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
    admin_role.destroy
    siteowner_role.destroy
    customer_role.destroy

    #Destroy all rights
    right = Right.find_by_name("*Access to all admin actions")
    right.destroy

    right = Right.find_by_name( "*Access to all pages actions")
    right.destroy

    right = Right.find_by_name( "*Access to all rights actions")
    right.destroy

    right = Right.find_by_name( "*Access to all roles actions")
    right.destroy

    right = Right.find_by_name( "*Access to all user actions")
    right.destroy

    right = Right.find_by_name( "*Access to all login actions")
    right.destroy
  end
end

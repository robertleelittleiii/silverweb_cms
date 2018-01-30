class Right < ActiveRecord::Base
  has_and_belongs_to_many :roles
  
    def action=(action_item)
   
   if  action.to_s.include?(action_item) then
     new_action_list =  action.to_s.split(",").select{|elem| elem != action_item}.join(",")
   else
     new_action_list = ( action.to_s.split(",") << action_item).join(",")
   end
   
  write_attribute(:action, new_action_list)
  
  # This is equivalent:
  # self[:name] = new_name.upcase
end
end

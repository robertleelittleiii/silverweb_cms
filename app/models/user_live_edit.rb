class UserLiveEdit < ActiveRecord::Base
 
  belongs_to :user, optional: true

  
  
  def current
  (current_type.constantize).find(current_id)
  end
  
end

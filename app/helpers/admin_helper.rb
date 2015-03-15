module AdminHelper
  def site_status(togglevalue)
  if togglevalue then 
          return("Site is DOWN (construction sign in place)")
        else
          return("Site is UP")
        end
  end
  
  def site_down
      if FileTest.exists?("public/index.html") then 
       return true
      else
        return false
      end
  end
  
end
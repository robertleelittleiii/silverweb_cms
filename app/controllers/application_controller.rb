# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class ApplicationController < ActionController::Base
  helper SilverwebCMS::Engine.helpers
  
 #  layout proc { false if request.xhr? }
  
  #layout Proc.new { |controller| controller.request.xhr? ? nil : 'application' }

  def calc_layout(default="application")
    if request.xhr? then
    false
  elsif params[:as_window] then
    "cms_dialog"
  else
    default
    end
  end
  
  
  def authenticate
    # put an exception here for self registration
  #  puts "In Authenticate"
  #  logger.info("controller #{self.class.controller_path}")
  #  logger.info("action: #{action_name}")

    if(self.class.controller_path == "users" && action_name=="create")

    else
      unless User.find_by_id(session[:user_id])
        session[:original_uri] = request.request_uri
        flash.now[:notice] = "Please log in"
   #     puts("redirected to admin/login.")
        redirect_to(:controller => "registration" , :action => "login" )
      end
    end
  end

  def authorize
    # put an exception here for self registration
    if(self.class.controller_path == "users" && action_name=="create")
    else
      user =  User.find_by_id(session[:user_id])
      unless !user.nil? and user.roles.detect{|role|
          role.rights.detect{|right|
            ((right.action == action_name)|(right.action == "*")|(right.action.include? action_name)) && right.controller == self.class.controller_path
          }
        }
        flash[:notice] = "You are not authorized to view the page you requested"
        request.env["HTTP_REFERER" ] ? (redirect_back(fallback_location: root_path)) : (redirect_to "")
        return false
      end
    end
  end
  
end

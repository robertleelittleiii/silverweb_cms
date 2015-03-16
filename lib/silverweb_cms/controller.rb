module SilverwebCms
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      # notice: no self.method_name here, because this is being extended because ActiveSupport::Concern was extended
      def layout_sub(layout_sub)
        before_filter do |c|
          #c.set_layout_sub_value(layout_sub)
          c.cms_layout(default="application")
        end
       
  
        #           before_filter :set_layout_sub_value=>{:layout_sub=>layout_sub} # to be available on every controller
      end
      
      def cms_authorize
        
         before_filter :authenticate,
          :authorize,
          :except => :login  
        
         include SilverwebCmsInternals

      end
      
      def cms_skip_authorize
        include SilverwebCmsSkipAuthentication
      end
    end
    # instance
    #    def set_layout_sub_value(layout_sub)
    #      @layout_sub = layout_sub
    #      #puts("layout sub called")
    #    end
    
    module SilverwebCmsInternals
      extend ActiveSupport::Concern

      def authenticate
        # put an exception here for self registration
        puts "In Authenticate"
        logger.error("controller #{self.class.controller_path}")
        logger.info("action: #{action_name}")

        if(self.class.controller_path == "users" && action_name=="create")

        else
          unless User.find_by_id(session[:user_id])
            session[:original_uri] = request.original_url 
            flash[:notice] = "Please log in"
            puts("redirected to admin/login.")
            redirect_to( "/" )
          end
        end
      end

      def authorize
        # put an exception here for self registration
        if(self.class.controller_path == "users" && action_name=="create")
        else
          user =  User.find_by_id(session[:user_id])
          
          if user.roles.where(:name=>"Admin").length>0 then
                Rack::MiniProfiler.authorize_request
          end
          
          unless user.roles.detect{|role|
              role.rights.detect{|right|
                ((right.action == action_name)|(right.action == "*")|(right.action.include? action_name)) && right.controller == self.class.controller_path
              }
            }
            flash[:notice] = "You are not authorized to view the page you requested"
            request.env["HTTP_REFERER" ] ? (redirect_to :back) : (redirect_to "")
            return false
          end
        end
      end
    end
    
    module SilverwebCmsSkipAuthentication
      extend ActiveSupport::Concern

      def authenticate
       return true
      end

      def authorize
       return true
      end
    end
  
    
      def cms_layout(default="application")
        if request.xhr? then
          false
        elsif params[:as_window] then
          "cms_dialog"
        else
          default
        end
      end

  end
end
module SilverwebCms
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      # notice: no self.method_name here, because this is being extended because ActiveSupport::Concern was extended
      def layout_sub(layout_sub)
        before_action do |c|
          #c.set_layout_sub_value(layout_sub)
          c.cms_layout(default="application")
        end
       
  
        #           before_filter :set_layout_sub_value=>{:layout_sub=>layout_sub} # to be available on every controller
      end
      
      def cms_authorize
        
        before_action :authenticate,
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
      
      def redirect_back_or_default(default = root_url, *args)
        if request.env['HTTP_REFERER'].present? && request.env['HTTP_REFERER'] != request.env['REQUEST_URI']
          redirect_to :back, *args
        else
          redirect_to default, *args
        end
      end
       
      def authenticate
        # put an exception here for self registration
        puts "In Authenticate"
        logger.info("controller #{self.class.controller_path}")
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
          
          session[:last_seen]=Time.now
          session[:ip_address]= request.remote_ip rescue "n/a"
           
          if !user.nil? and user.roles.where(:name=>"Admin").length>0 and Settings.activate_rack_mini_profiler.to_s=="true" then
            Rack::MiniProfiler.authorize_request
          end
          
          if ['edit', 'index'].include? action_name  then
            session[:current_action] = action_name
            session[:current_controller] = self.class.controller_path.classify
            session[:current_record_id] = params[:id]
            if user.user_live_edit.blank? then
              user.user_live_edit = UserLiveEdit.new
            end
            user.user_live_edit.current_type = self.class.controller_path.classify
            user.user_live_edit.current_action = action_name
            user.user_live_edit.current_id = params[:id]
            user.user_live_edit.save      
          end
          unless !user.nil? and user.roles.detect{|role|
              role.rights.detect{|right|
                ((right.action == action_name)|(right.action == "*")|(right.action.include? action_name)) && right.controller == self.class.controller_path
              }
            }
            flash[:notice] = "You are not authorized to view the page you requested (Action: #{action_name}, Controller: #{self.class.controller_path})"
            request.env["HTTP_REFERER" ] ? (redirect_to :back) : (redirect_to "")
            return false
          end
        end
      end
      
      def update_user_field
        current_user =  User.find_by_id(session[:user_id])

        current_user.user_live_edit.current_field = params[:current_field]
        current_user.user_live_edit.save
        render :nothing=>true

      end
  
      def refresh_user_live_edit
        user =  User.find_by_id(session[:user_id])
      
        session[:current_action] = params[:user_action_name]
        session[:current_controller] = self.class.controller_path.classify
        session[:current_record_id] = params[:id]
              
        user.user_live_edit.current_type = self.class.controller_path.classify
        user.user_live_edit.current_action = params[:user_action_name]
        user.user_live_edit.current_id = params[:id]
        user.user_live_edit.save      
        
        render :nothing=>true

      end
  
      def get_field
        the_value =  self.class.controller_path.classify.constantize.find(params[:id]).send(params[:field_name]) rescue ""
    
        case the_value.class.to_s
        when "Date"
          return_value = Date.parse(the_value.to_s).strftime(params[:format_string])
        when "Time"
          return_value = Time.parse(the_value.to_s).strftime(params[:format_string])
        else
          return_value = the_value
        end
    
        render :text=>return_value
      end

    end
    
    module SilverwebCmsSkipAuthentication
      extend ActiveSupport::Concern

      def authenticate
        session[:init] = true

        return true
      end

      def authorize
        session[:init] = true

        return true
      end
    end
  
    
    def cms_layout(default="application")
      puts("params in cms_layout: #{params.inspect}")
      if request.xhr? then
        false
      elsif params[:as_window] then
        "cms_dialog"
      elsif (params[:window_type]=="iframe")
        "application_iframe" 
      else
        default
      end
    end
  
    def cms_layout_new(default="application")
      session["iframe"] = false
      if request.xhr? then
        return false
      elsif (params[:window_type]=="iframe") then
        session["iframe"] = true
        return "cms_iframe" 
      elsif params[:as_window] then
        return "cms_dialog"
      else
        return default
      end rescue "application"
      return default
    end
  end
end
class SiteController < ApplicationController

  require "silverweb_cms/base"

  helper ApplicationHelperSiteSpecific rescue ""
  
  # before_filter :find_cart, :except => :empty_cart

  cms_skip_authorize
  
  protect_from_forgery :except => [:set_time_zone, :session_active]

  # uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:new, :edit])

  # login code
  
  # layout "cms_dialog", only: [:code_mirror]
   
  def login
  
    respond_to do |format|
      format.html # new.html.erb
      format.json  { head :ok }
    end
  end
  
  def reset
    @user = User.find_by_password_reset_code(params[:reset_code]) unless params[:reset_code].empty?
    if @user.nil?
      flash.now[:notice] = "Password has already been reset!"
    end
    respond_to do |format|
      if !@user.nil?
        format.html # new.html.erb
        format.json  { head :ok }
      else
        format.html { render plain: flash.now[:notice], status: :non_authoritative_information, content_type: "application/json" }
        format.json  { render :json => @menu.errors, :status => :unprocessable_entity }
      end
    
    end
  end
  
  def two_factor_ajax
    user, twofactor = User.two_factor_auth(params[:code])
    
    if twofactor then
      session[:active]=true
      session[:last_seen]=Time.now
      session[:ip_address]= request.remote_ip rescue "n/a"

      session[:user_id] = user.id
      login_success = true
      flash.now[:notice] = "Login Sucessfull, Welcome!!"
      uri = session[:original_uri]
      session[:original_uri] = nil
      login_sucess = true
      twofactor = false
      code_expired = false
    else
      user = User.find(session[:temp_user_id])
      code_age = ((user.updated_at + user.secret_life) -  DateTime.now).round
      if code_age <= 0 
        flash.now[:notice] = "Code has expired, please login again."
        code_expired = true

      else
        flash.now[:notice] = "Wrong code, please try again (code expires in #{Time.at(code_age).utc.strftime "%H hr %M min %S sec"
})"
      end
      twofactor = true
      login_sucess = true
    end
    
    respond_to do |format|
      #   format.js {head :ok}   
      #   format.json {head :ok}
      format.json  {render :json=>{:message=>flash[:notice],:sucessfull=>login_success,:twofactor=>twofactor, :code_expired=>code_expired, :uri=>uri}}
      format.html {redirect_to(uri || { :action => "index" })}
    end  
  end
  

  #ajax login code
  def login_ajax
    session[:user_id] = nil
    session[:active] = false
    fail_count_max = (Settings.fail_count_max || 3) rescue 3

    status_code, @results = AbstractApi::GeoData.make_request(request.remote_ip)
    
    user, logged_in, twofactor = User.authenticate(params[:name], params[:password], @results)
    #  puts("User: #{user.inspect}") 
    session[:temp_user_id] = user.id unless user.nil?
    if twofactor 
      if user.settings.two_factor_method == "Text" and not (user.formated_phone_number.nil? or user.formated_phone_number.blank?)
        TwilioApi.send_sms(user.formated_phone_number,"Your Security Code is #{user.two_factor_code}")
      else
        UserNotifier.two_factor_notification(user, $hostfull).deliver
      end
    end
    

    login_success = false
    
    if logged_in and not twofactor then
      # reset_session

      session[:active]=true
      session[:last_seen]=Time.now
      session[:ip_address]= request.remote_ip rescue "n/a"

      session[:user_id] = user.id
      login_success = true
      flash.now[:notice] = "Login Sucessfull, Welcome!!"
      uri = session[:original_uri]
      session[:original_uri] = nil
    else
      if twofactor 
        comm_method = user.formated_phone_number.blank? ? "email" : user.settings.two_factor_method || "email"
        flash.now[:notice] = "You need to veryfy your account.  Enter code sent to you via #{comm_method}."
      elsif !user.nil? and user.auth_fail_count.to_i >= fail_count_max
        flash.now[:notice] = "User Account Locked! Too many failed attempts"
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end 
    
    respond_to do |format|
      #   format.js {head :ok}   
      #   format.json {head :ok}
      format.json  {render :json=>{:message=>flash[:notice],:sucessfull=>login_success,:twofactor=>twofactor, :uri=>uri}}
      format.html {redirect_to(uri || { :action => "index" })}
    end  
  end
  
  def logout_ajax
    session[:user_id] = nil
    session[:active]=false
    flash.now[:notice] = "User logged out."
    reset_session

    respond_to do |format|
      format.json  {render :json=>{:message=>flash[:notice]}}
      format.html {head :ok}
    end
  end
  
  #
  #
  #
  
  def reset_ajax
    #  @hostfull =
    $hostfull=request.protocol + request.host_with_port
    @hostfull=$hostfull
    if request.post?
      @user = User.find_by_name(params[:name])
      if @user
        @user.create_reset_code
        UserNotifier.reset_notification(@user, $hostfull).deliver
        #         UserNotifier.reset_notification2(@user, @hostfull)
        message = "Reset code sent to #{@user.name}"
      else
        message = "#{params[:name]} does not exist in system"
      end
      respond_to do |format|
        #   format.js {head :ok}   
        #   format.json {head :ok}
        format.json  {render :json=>{:message=>message}}
        format.html {redirect_to(uri || { :action => "index" })}
      end 
    end
  end
  
  def check_session
        
    respond_to do |format|
      format.json  {render :json=>{:exists=>(!session.blank? rescue false)}}
    end 
  end
  #
  #
  #
  def register_ajax
    
    uri =  session[:original_uri]
    $hostfull=request.protocol + request.host_with_port
    login_success = false
    @user = User.find_by_name(params[:user][:name])
    @regtype=params[:register][:regtype]||""
    if not @user then
      if request.post? and params[:user]
        @user = User.create(params[:user].permit("name", "password", "password_confirmation"))
          
        @role_name = params[:register][:role]
        @role = Role.find_by_name(@role_name)
        @user.roles << @role

        @user_attribute = UserAttribute.create(params[:user_attributes].permit("first_name", "last_name"))
        @user_attribute.user_id=@user.id
        @user_attribute.save
      
        if @user.save
            
          #     @user.add_to_constant_contact
          @user.create_activation_code
          flash[:notice] = @role_name +" account created."
          session[:user_id] = @user.id
          session[:original_uri] = nil
          UserNotifier.signup_notification(@user, $hostfull).deliver
          login_success = true
        else
          flash[:notice] = @user.errors.full_messages.join("<br>")
        end
      end

    else
      flash[:notice] = "User already Exists, please try again."
    end
    
    respond_to do |format|
      format.json  {render :json=>{:message=>flash[:notice],:sucessfull=>login_success, :uri=>uri}}
      format.html {redirect_to(uri || {:controller=>"admin",  :action => "index" })}
    end 
    
    # puts("NOTICE====> #{flash[:notice]}")

  end
  
  def render_partial
    @user =  User.find_by_id(session[:user_id])
    if @user.blank? then
      render :json => {"error"=>"session_invalid"}, :format=>"json", status => :unprocessable_entity

    else
      render :partial => params[:partial_name], :format=>"html"
    end
    
  end
  
  def get_csrf_meta_tags
    
    render json: {:request_token => request_forgery_protection_token, :authenticity_token => form_authenticity_token } 
  end
  
  #
  #
  #
  
  def index
    session[:mainnav_status] = false
    @alert = params[:alert] || ""
    #   @page = Page.find(params[:id]) rescue ""
    #    puts("via ID : #{@page}")
    # @page = Page.find_by_title(params[:page_name]) if @page.blank? 
    #  puts("via page_name : #{@page}")

    #  @page = Page.find_by_title("Home") if @page.blank?
    #   puts("Home : #{@page}")

    
    #  @page = Page.new(:title=>"'Home' not found.", :body=>"'Home' not found.") if @page.blank?
    #   puts("Not Found : #{@page.inspect}")
    @page = ((Page.find_by_id(params[:id]) || Page.find_by_title(params[:page_name]) || (params[:page_name].blank? ? nil : Page.where('lower(title) = ?', params[:page_name].gsub("_"," ").gsub("-"," ").downcase).first) || Page.find_by_slug(params[:page_name])) || Page.find_by_slug(Settings.home_page_name) || Page.find_by_title(Settings.home_page_name) || Page.find_by_title("Home")) || Page.new(:title=>"'Home' not found.", :body=>"'Home' not found.")   
   
    # puts ("Page Found : #{@page.inspect}")
 
    @user =  User.find_by_id(session[:user_id])

    #   if (@page.secure_page and @user.blank?)
    #  ApplicationController.instance_method(:authenticate).bind(self).call
    #     puts("*********** authenticate ************* #{@user.inspect}")
    # authorized =  ApplicationController.instance_method(:authorize).bind(self).call
    # authenticated =  ApplicationController.instance_method(:authenticate).bind(self).call
    # puts("authorized: #{authorized} authenticated: #{authenticated}")
    #   else    
    
    @page_template = (not @page.template_name.blank?) ? "show_page-" + @page.template_name : "show_page" rescue "show_page" 
    @java_script_custom = @page.template_name ? @page_template + ".js" : "" rescue ""
    @style_sheet_custom = @page.template_name ? @page_template + ".css" : "" rescue ""

    @page_name = @page.title rescue "'Home' not found!!"
    
    @menu = @page.menu rescue nil
    
    @page.revert_to(params[:version].to_i) if params[:version]

    
    #puts("@page:  Status #{@page.inspect}") 
    #puts("@alert:  Status #{@alert.inspect}") 
    
    # if params[:top_menu] 
    session[:parent_menu_id] = @menu.id rescue 0
    #   end
        
    #  puts("parent menu id:", session[:parent_menu_id])
    if params[:dialog]== true then
      
    end
    
    user_roles = @user.roles.map {|i| i.name } rescue  []
    # puts("************user roles: #{user_roles.inspect}, page_roles: #{@page.security_group_list.inspect}, VAlid: #{(user_roles & (@page.security_group_list)).blank?}")
   
    if @page.secure_page and ((user_roles) & (@page.security_group_list)).blank? then
      redirect_to :controller=>:site, :alert=>"You do not have permission to view that page."
    else
      respond_to do |format|
        format.html { render :action=>@page_template} # show.html.erb
        format.xml  { render :xml => @page }
        format.any  {render :json=>"An error has occured."}
      end
    end
    #   end
  end

  
  #  these were moved to allow free (un authorized) access so that the TMC editor can be used 
  #  freely without being limited to have access to creae pages.
  
  def custom
    @page = Page.find(session[:current_page]) rescue ""
    
    respond_to do |format|
      format.css 
    end
  end
  
  def link_list
    @pages = Page.order(:title)
    @pdfs = Picture.where("image like '%.pdf'") rescue []
    @last_pdf = @pdfs.last rescue ""
    @last_page = @pages.last
  end
  
  def template_list
    @page_templates = PageTemplate.order(:title)
    
    @last_page_template = @page_templates.last
  end

  def show_page_popup
    session[:mainnav_status] = false
    #  puts("page_id: #{params[:page_id]}")
    # puts("page_name: #{params[:page_nam]}")
    unless params[:page_id].blank? then 
      @page = Page.find_by_id(params[:page_id])
    else
      @page = ((Page.find_by_title(params[:page_name]) || (params[:page_name].blank? ? nil : Page.where('lower(title) = ?', params[:page_name].gsub("_"," ").gsub("-"," ").downcase).first) || Page.find_by_slug(params[:page_name])) || Page.find_by_slug(Settings.home_page_name) || Page.find_by_title(Settings.home_page_name) || Page.find_by_title("Home")) || Page.new(:title=>"#{params[:page_name]} not found.", :body=>"'#{params[:page_name]}' not found.")   
    end
  end
    
  
  def show_page
    session[:mainnav_status] = false
    @alert = params[:alert] || ""
    #   @page = Page.find(params[:id]) rescue ""
    #    puts("via ID : #{@page}")
    # @page = Page.find_by_title(params[:page_name]) if @page.blank? 
    #  puts("via page_name : #{@page}")

    #  @page = Page.find_by_title("Home") if @page.blank?
    #   puts("Home : #{@page}")

    
    #  @page = Page.new(:title=>"'Home' not found.", :body=>"'Home' not found.") if @page.blank?
    #   puts("Not Found : #{@page.inspect}")
    @page = ((Page.find_by_id(params[:id]) || Page.find_by_title(params[:page_name]) || (params[:page_name].blank? ? nil : Page.where('lower(title) = ?', params[:page_name].gsub("_"," ").gsub("-"," ").downcase).first) || Page.find_by_slug(params[:page_name])) || Page.find_by_slug(Settings.home_page_name) || Page.find_by_title(Settings.home_page_name) || Page.find_by_title("Home")) || Page.new(:title=>"'Home' not found.", :body=>"'Home' not found.")   
    # puts ("Page Found : #{@page.inspect}")
 
    @user =  User.find_by_id(session[:user_id])

    #   if (@page.secure_page and @user.blank?)
    #      puts("*********** authenticate ************* #{@user.inspect}")
    #  authorized =  ApplicationController.instance_method(:authorize).bind(self).call
    # authenticated =  ApplicationController.instance_method(:authenticate).bind(self).call
    # puts("authorized: #{authorized} authenticated: #{}")
    #    else    
    
    @page_template = (not @page.template_name.blank?) ? "show_page-" + @page.template_name : "show_page" rescue "show_page" 
    @java_script_custom = @page.template_name ? @page_template + ".js" : "" rescue ""
    @style_sheet_custom = @page.template_name ? @page_template + ".css" : "" rescue ""

    @page_name = @page.title rescue "'Home' not found!!"
    
    @menu = @page.menu rescue nil
    
    @page.revert_to(params[:version].to_i) if params[:version]

    
    #puts("@page:  Status #{@page.inspect}") 
    #puts("@alert:  Status #{@alert.inspect}") 
    
    # if params[:top_menu] 
    session[:parent_menu_id] = @menu.id rescue 0
    #   end
        
    # puts("parent menu id:", session[:parent_menu_id])
    if params[:dialog]== true then
      
    end
    
    user_roles = @user.roles.map {|i| i.name } rescue  []
    # puts("************user roles: #{user_roles.inspect}, page_roles: #{@page.security_group_list.inspect}, VAlid: #{(user_roles & (@page.security_group_list)).blank?}")
   
    if @page.secure_page and ((user_roles) & (@page.security_group_list)).blank? then
      redirect_to :controller=>:site, :alert=>"You do not have permission to view that page, please login.", :login=>true, :url=>request.original_url
    else
      respond_to do |format|
        format.html { render :action=>@page_template} # show.html.erb
        format.xml  { render :xml => @page }
        format.any  { render :json=>"An error has occured."}
      end
    end
    #   end
  end

  
  def show_prop_slideshow
    @properties = Property.find_properties(params[:realtor_id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  def show_prop_slideshow_partial
    @properties = Property.find_properties(params[:realtor_id])
    render :partial => "show_prop_slideshow", :format=>"html"
  end
  
  def  session_active
    render plain: session[:active] || "false" rescue "false"
  end
  
  #  def show_products_with_page
  #    begin
  #      @page_info = Page.find(params[:page_id]) 
  #      #@menu = @page_info.menu
  #      
  #      if params[:top_menu] 
  #        puts("top_menu id: #{@menu.name}")
  #        session[:parent_menu_id] = @menu.id rescue 0
  #      end
  #    rescue 
  #      # flash[:notice] = "No page selected for menu'#{@category_id}'"
  #    end
  #    
  #    session[:mainnav_status] = false
  #    session[:last_catetory] = request.env['REQUEST_URI']
  #    @page_name=Menu.find(session[:parent_menu_id]).name rescue ""
  #    
  #    @products_per_page = Settings.products_per_page.to_i || 8
  #    @category_id = params[:category_id] || ""
  #    @department_id = params[:department_id] || ""
  #    @category_children = params[:category_children] || false
  #    @get_first_submenu = params[:get_first_sub] || false
  #    @the_page = params[:page] || "1"
  #    
  #    @menu = Menu.where(:name=>@category_id).first 
  #  
  #    #  @parent_menu = Menu.where(:name=>@department_id).first
  #    #  @menu = @parent_menu.menus.where(:name=>@category_id).first || @parent_menu.menus.first rescue Menu
  #   
  #    #@menu = Menu.where(:name=>@department_id).joins(:menus).where(:menus_menus=>{:name=>catetory_id})
  #
  #    #updated fix for 
  #    if params[:top_menu] and @get_first_submenu == "true" then
  #      @menu = Menu.where(:name=>@department_id).first 
  #      # puts("top_menu id: #{@menu.menus[0].name}")
  #      session[:parent_menu_id] = @menu.id rescue 0 
  #      @menu = @menu.menus.where(:name=>@category_id).first || @menu.menus.first
  #      @category_id = @menu.name rescue "n/a"
  #
  #    end
  #      
  #    #@page_name=Menu.find(session[:parent_menu_id]).name rescue ""
  #    begin 
  #      if @category_children == "true" then
  #        @categories =  create_menu_lowest_child_list(@category_id, nil,false) + [@category_id]
  #        puts("categories: #{@categories.inspect} ")
  #        @products_list = Product.where(:product_active=>true).tagged_with(@categories, :any=>true, :on=>:category).tagged_with(@department_id, :on=>:department)
  #
  #      else
  #        if @category_id.blank? or @department_id.blank? then
  #          @products_list = Product.where(:product_active=>true)
  #        else
  #          @products_list = Product.where(:product_active=>true).tagged_with(@category_id, :on=>:category).tagged_with(@department_id, :on=>:department)
  #        end
  #      end
  #    rescue
  #      @products_list = Product.all
  #    end
  #    
  #    @product_ids = @products_list.collect{|prod| prod.id }
  #
  #    @product_count = @products_list.length
  #
  #    # @products = Kaminari.paginate_array(@products).page(params[:page]).per(@products_per_page)
  #    @products = Product.where(:id=>@product_ids).order("product_ranking DESC").order("position ASC").order("created_at DESC").page(params[:page]).per(@products_per_page)
  #    #    @products = @products.page(params[:page]).per(@products_per_page)
  #
  #    @product_first = params[:page].blank? ? "1" : (params[:page].to_i*@products_per_page - (@products_per_page-1))
  #    
  #    @product_last = params[:page].blank? ? @products.length : ((params[:page].to_i*@products_per_page) - @products_per_page) + @products.length || @products.length
  #
  #    @layout = params[:custom_layout] ? params[:custom_layout] : "show_products_with_page"
  #    @java_script_custom = params[:custom_layout] ? params[:custom_layout] + ".js" : "" rescue ""
  #    @style_sheet_custom = params[:custom_layout] ? params[:custom_layout] + ".css" : "" rescue ""
  #   
  #    respond_to do |format|
  #      format.html {render :controller=>:site, :action=>@layout}
  #      format.xml  {render :xml=>@products}
  #    end
  #  end
  #  
  #  def show_products
  #    session[:mainnav_status] = false
  #    session[:last_catetory] = request.env['REQUEST_URI']
  #    @page_name=Menu.find(session[:parent_menu_id]).name rescue ""
  #    
  #    @products_per_page = Settings.products_per_page.to_i || 8
  #    @category_id = params[:category_id] || ""
  #    @department_id = params[:department_id] || ""
  #    @category_children = params[:category_children] || false
  #    @get_first_submenu = params[:get_first_sub] || false
  #    @the_page = params[:page] || "1"
  #    
  #    @menu = Menu.where(:name=>@category_id).first 
  #  
  #    if params[:top_menu] and @get_first_submenu == "true" then
  #      # puts("top_menu id: #{@menu.menus[0].name}")
  #      session[:parent_menu_id] = @menu.id rescue 0
  #      @menu = @menu.menus[0]
  #      @category_id = @menu.name rescue "n/a"
  #
  #    end
  #      
  #    #@page_name=Menu.find(session[:parent_menu_id]).name rescue ""
  #    begin 
  #      if @category_children == "true" then
  #        @categories =  create_menu_lowest_child_list(@category_id, nil,false) + [@category_id]
  #        puts("categories: #{@categories.inspect} ")
  #        @products_list = Product.where(:product_active=>true).tagged_with(@categories, :any=>true, :on=>:category).tagged_with(@department_id, :on=>:department)
  #
  #      else
  #        if @category_id.blank? or @department_id.blank? then
  #          @products_list = Product.where(:product_active=>true)
  #        else
  #          @products_list = Product.where(:product_active=>true).tagged_with(@category_id, :on=>:category).tagged_with(@department_id, :on=>:department)
  #        end
  #      end
  #    rescue
  #      @products_list = Product.all
  #    end
  #    
  #    @product_ids = @products_list.collect{|prod| prod.id }
  #
  #    @product_count = @products_list.length
  #
  #    # @products = Kaminari.paginate_array(@products).page(params[:page]).per(@products_per_page)
  #    @products = Product.where(:id=>@product_ids).order("product_ranking DESC").order("position ASC").order("created_at DESC").page(params[:page]).per(@products_per_page)
  #    #    @products = @products.page(params[:page]).per(@products_per_page)
  #
  #    @product_first = params[:page].blank? ? "1" : (params[:page].to_i*@products_per_page - (@products_per_page-1))
  #    
  #    @product_last = params[:page].blank? ? @products.length : ((params[:page].to_i*@products_per_page) - @products_per_page) + @products.length || @products.length
  #
  #
  #    respond_to do |format|
  #      format.html # show.html.erb
  #      format.xml  { render :xml => @products }
  #    end
  #  end
  #  
  #
  #  def show_products_services
  #    session[:mainnav_status] = false
  #    session[:last_catetory] = request.env['REQUEST_URI']
  #    @page_name=Menu.find(session[:parent_menu_id]).name rescue ""
  #    
  #    @products_per_page = Settings.products_per_page.to_i || 8
  #    @category_id = params[:category_id] || ""
  #    @department_id = params[:department_id] || ""
  #    @category_children = params[:category_children] || false
  #    @get_first_submenu = params[:get_first_sub] || false
  #    
  #    @page_info = Page.find_by_title(params[:page]) || Page.find_by_title("Show Products Services") ||  Page.new(:title=>"Page 'Show Products Services' not found.", :body=>"Page 'Show Products Services' not found.")
  #
  #    @menu = Menu.where(:name=>@category_id).first 
  #  
  #    if params[:top_menu] and @get_first_submenu == "true" then
  #      # puts("top_menu id: #{@menu.menus[0].name}")
  #      session[:parent_menu_id] = @menu.id rescue 0
  #      @menu = @menu.menus[0]
  #      @category_id = @menu.name rescue "n/a"
  #
  #    end
  #      
  #    #@page_name=Menu.find(session[:parent_menu_id]).name rescue ""
  #    begin 
  #      if @category_children == "true" then
  #        @categories =  create_menu_lowest_child_list(@category_id, nil,false) + [@category_id]
  #        puts("categories: #{@categories.inspect} ")
  #        @products_list = Product.where(:product_active=>true).tagged_with(@categories, :any=>true, :on=>:category).tagged_with(@department_id, :on=>:department)
  #
  #      else
  #        if @category_id.blank? or @department_id.blank? then
  #          @products_list = Product.where(:product_active=>true)
  #        else
  #          @products_list = Product.where(:product_active=>true).tagged_with(@category_id, :on=>:category).tagged_with(@department_id, :on=>:department)
  #        end
  #      end
  #    rescue
  #      @products_list = Product.all
  #    end
  #    
  #    @product_ids = @products_list.collect{|prod| prod.id }
  #
  #    @product_count = @products_list.length
  #
  #    # @products = Kaminari.paginate_array(@products).page(params[:page]).per(@products_per_page)
  #    @products = Product.where(:id=>@product_ids).order("product_ranking DESC").order("position ASC").order("created_at DESC").page(params[:page]).per(@products_per_page)
  #    #    @products = @products.page(params[:page]).per(@products_per_page)
  #
  #    @product_first = params[:page].blank? ? "1" : (params[:page].to_i*@products_per_page - (@products_per_page-1))
  #    
  #    @product_last = params[:page].blank? ? @products.length : ((params[:page].to_i*@products_per_page) - @products_per_page) + @products.length || @products.length
  #
  # 
  #    respond_to do |format|
  #      format.html # show.html.erb
  #      format.xml  { render :xml => @products }
  #    end
  #  end
  #  
  #  def show_products_services_simple
  #    session[:mainnav_status] = false
  #    session[:last_catetory] = request.env['REQUEST_URI']
  #    @page_name=Menu.find(session[:parent_menu_id]).name rescue ""
  #    
  #    @products_per_page = Settings.products_per_page.to_i || 8
  #    @category_id = params[:category_id] || ""
  #    @department_id = params[:department_id] || ""
  #    @category_children = params[:category_children] || false
  #    @get_first_submenu = params[:get_first_sub] || false
  #    
  #    @page_info = Page.find_by_title(params[:page]) || Page.find_by_title("Gift Cards") ||  Page.new(:title=>"Page 'Gift Cards' not found.", :body=>"Page 'Gift Cards' not found.")
  #
  #    @menu = Menu.where(:name=>@category_id).first 
  #  
  #    if params[:top_menu] and @get_first_submenu == "true" then
  #      # puts("top_menu id: #{@menu.menus[0].name}")
  #      session[:parent_menu_id] = @menu.id rescue 0
  #      @menu = @menu.menus[0]
  #      @category_id = @menu.name rescue "n/a"
  #
  #    end
  #      
  #    #@page_name=Menu.find(session[:parent_menu_id]).name rescue ""
  #    begin 
  #      if @category_children == "true" then
  #        @categories =  create_menu_lowest_child_list(@category_id, nil,false) + [@category_id]
  #        puts("categories: #{@categories.inspect} ")
  #        @products_list = Product.where(:product_active=>true).tagged_with(@categories, :any=>true, :on=>:category).tagged_with(@department_id, :on=>:department)
  #
  #      else
  #        if @category_id.blank? or @department_id.blank? then
  #          @products_list = Product.where(:product_active=>true)
  #        else
  #          @products_list = Product.where(:product_active=>true).tagged_with(@category_id, :on=>:category).tagged_with(@department_id, :on=>:department)
  #        end
  #      end
  #    rescue
  #      @products_list = Product.all
  #    end
  #    
  #    @product_ids = @products_list.collect{|prod| prod.id }
  #
  #    @product_count = @products_list.length
  #
  #    # @products = Kaminari.paginate_array(@products).page(params[:page]).per(@products_per_page)
  #    @products = Product.where(:id=>@product_ids).order("product_ranking DESC").order("position ASC").order("created_at DESC").page(params[:page]).per(@products_per_page)
  #    #    @products = @products.page(params[:page]).per(@products_per_page)
  #
  #    @product_first = params[:page].blank? ? "1" : (params[:page].to_i*@products_per_page - (@products_per_page-1))
  #    
  #    @product_last = params[:page].blank? ? @products.length : ((params[:page].to_i*@products_per_page) - @products_per_page) + @products.length || @products.length
  #
  # 
  #    respond_to do |format|
  #      format.html # show.html.erb
  #      format.xml  { render :xml => @products }
  #    end
  #  end
  

  #  def live_search
  #    
  #    session[:mainnav_status] = false
  #    session[:last_catetory] = request.env['REQUEST_URI']
  #    @page_name=Menu.find(session[:parent_menu_id]).name rescue ""
  #    
  #    @products_per_page = Settings.search_products_per_page.to_i || 8
  #    @category_id = params[:category_id] || ""
  #    @department_id = params[:department_id] || ""
  #    @category_children = params[:category_children] || false
  #
  #      
  #      
  #    @search = params[:search]
  #   
  #    session[:search] = params[:search].strip if params[:search]
  #    
  #    @history = (session[:history] || "[Nothing...]").split(":,:")
  #     
  #    if (not @history.include?(params[:search]) and not params[:search].blank?) then
  #      session[:history] = "" + (session[:history].blank? ? "" : (session[:history] ) ) + (session[:search].blank? ? "" :":,:" + session[:search])    
  #      @history = (session[:history] || "[Nothing...]").split(":,:")
  #      @history = @history[1..10] if @history.size > 10
  #      session[:history] = @history.join(":,:");
  #    end
  #     
  #   
  #
  #    @products = Product.by_search_term(session[:search])
  #
  #    # @products = Product.find_products_search(params[:page], session[:search])
  #    
  #    @product_count = @products.length
  #
  #    @products = Kaminari.paginate_array(@products).page(params[:page]).per(@products_per_page)
  #    
  #    @product_first = params[:page].blank? ? "1" : (params[:page].to_i*@products_per_page - (@products_per_page - 1))
  #    
  #    @product_last = params[:page].blank? ? @products.length : ((params[:page].to_i*@products_per_page) - @products_per_page) + @products.length || @products.length
  #
  #
  #    if session[:search] and request.xhr?
  #      render  :action=>"show_products_search"
  #    else
  #    
  #    
  #      respond_to do |format|
  #        format.js  { render :action=>"show_products_search"}
  #        format.html { render :action=>"show_products_search"}
  #        format.xml  { render :xml => @products }
  #        format.json { render :json=> @products }
  #      end
  #    end
  #    #    render body: nil
  #  end
  #  
  #
  #
  #
  #
  #
  #  def get_sizes_for_color 
  #    
  #    @product = Product.find(params[:id]) 
  #
  #    @product_sizes_list = @product.product_details.select("distinct `size`, `units_in_stock`").where("`color` = '#{params[:color]}'").where(:sku_active=>true)  || [{:size=>'N/S', :units_in_stock=>"0"}] rescue [{:size=>'N/S', :units_in_stock=>"0"}]
  #    @product_size_array = @product_sizes_list.map{ |f| f.size }
  #   
  #    @product_sizes = []
  #    
  #    sizes =  ["N/S"] + Settings.inventory_size_list.split(",") rescue ["N/S"]
  #    
  #    sizes.each_with_index do |each_item, counter|
  #      if  @product_size_array.include?(each_item)==true then
  #        @product_sizes << @product_sizes_list.where(:size=>each_item).first
  #      end
  #    end
  #    
  #    
  #    render :partial=>"sizes_list.html"
  #  end
  #  
  #  def product_detail
  #
  #    session[:mainnav_status] = false
  #    if params[:id].blank? then
  #      @product = Product.first
  #    else
  #      @product = Product.find(params[:id]) 
  #    end
  #    
  #    if params[:next] then
  #      @product = @product.next_in_collection
  #      puts "=======NEXT========"
  #    end
  #    
  #    if params[:prev] then
  #      @product = @product.previous_in_collection
  #      puts "=======PREV======="
  #
  #    end
  #    @menu_id= session[:parent_menu_id] || 0
  #    @menu = Menu.find(@menu_id) rescue Menu.all[0]
  #    
  #    # session[:parent_menu_id] = 0
  #    @page_template = (not @product.custom_layout.blank?) ? "product_detail-" + @product.custom_layout : "product_detail" rescue "product_detail" 
  #    @java_script_custom = @product.custom_layout ? @page_template + ".js" : "" rescue ""
  #    @style_sheet_custom = @product.custom_layout ? @page_template + ".css" : "" rescue ""
  #    @page_name = @product.product_name rescue "'Home' not found!!"
  #    
  #    @collection_product_list = Product.all()
  #    @pictures = @product.pictures.where(:active_flag=>true)
  #    
  #    @sizing_page = Page.find_by_title(@product.sheet_name + " Sizing") rescue ""
  #    @care_page = Page.find_by_title(@product.sheet_name + " Care") rescue ""
  #
  #    @product_details = @product.product_details
  #    @product_colors = @product_details.group(:color).where(:sku_active=>true) || [{:size=>'N/C'}] rescue [{:size=>'N/C'}]
  #    @product_sizes_list = @product_details.select("distinct `size`, `units_in_stock`").where("`color` = '#{@product_colors[0].color}'").where(:sku_active=>true)  || [{:size=>'N/S', :units_in_stock=>"0"}] rescue [{:size=>'N/S', :units_in_stock=>"0"}]
  #    @product_size_array = @product_sizes_list.map{ |f| f.size }
  #   
  #    @product_sizes = []
  #    
  #    sizes =  ["N/S"] + Settings.inventory_size_list.split(",") rescue ["N/S"]
  #    
  #    sizes.each_with_index do |each_item, counter|
  #      if  @product_size_array.include?(each_item)==true then
  #        @product_sizes << @product_sizes_list.where(:size=>each_item).first
  #      end
  #    end
  #
  #    
  #    respond_to do |format|
  #      format.html { render :action=>@page_template} # show.html.erb
  #      format.xml  { render :xml => @page }
  #    end
  #    
  #  end
  #  
  #  #
  #  #
  #  #check out
  #  #
  #  #
  #  def check_out
  #    find_cart
  #
  #    @shipping_methods = [["Ground",0] , ["2 Day",1], ["Next Day",2], ["Pick Up Store",3]]
  #    @shipping_methods =  Settings.shipping_methods.split(",").each_with_index.map || "" rescue [["none found!!",0]]
  #
  #    
  #    if @cart.items.empty?
  #      redirect_to(:controller => "site", :action => "index")
  #    else
  #      #@cart.hide
  #      #@cart.set_shipping(@cart.calc_shipping)
  #      #@order = Order.new
  #
  #
  #     
  #    end
  #  end
  #  
  #  #
  #  #  Shopping Cart 
  #  #
  #  
  #  
  #  def add_to_cart
  #    @cart=Cart.get_cart("cart"+session[:session_id])
  #
  #    #    @cart = Cart.get_cart(session[:cart])
  #    #    session[:cart] = @cart.id
  #    #  puts("cart id: #{@cart.id}")
  #       
  #    @flash_message = ""
  #    
  #    @product_detail=ProductDetail.where(:product_id=>params[:id], :color=>params[:color], :size=>params[:size]).first()
  #    # puts("Product in Add: #{@product_detail.product.inspect}")
  #    #  puts("Product Detail In Add: #{@product_detail.inspect}")
  #    inventory_item_description=params.map {|k,vs| vs.map {|v| "#{k}:#{v}"}}.join(",")
  #    begin
  #      @current_item = @cart.add_product(@product_detail.product, @product_detail, params[:quantity])
  #      puts("Quantity Ordered: #{@current_item.quantity.inspect}")
  #      if (@current_item.quantity > @product_detail.units_in_stock) then
  #        puts("cart quantity:#{@current_item.quantity }, unit in stock: #{@product_detail.units_in_stock}")
  #        @flash_message ='Your request exceeds current inventory, your quantity has been reduced to what we have in stock.'
  #        # @current_item.quantity = @product_detail.units_in_stock.to_i
  #      else if @product_detail.units_in_stock == 0 then
  #          @flash_message = "That product is currently unavailable."
  #        end
  #      end
  #    rescue 
  #      @flash_message = "Your request exceeds current inventory."
  #
  #    end
  #    respond_to do |format|
  #      format.json  { head :ok }
  #      format.html { render :text=>@flash_message }
  #    end
  #  end
  #
  #  def hide_cart
  #    find_cart
  #    unless not @cart.visable then
  #      @cart.hide
  #      respond_to do |format|
  #        format.js if request.xhr?
  #        format.html {redirect_to :controller => 'store', :action => 'store_list'}
  #      end
  #    end
  #  end
  #
  #  
  #  def show_cart
  #    # @cart = (session[:cart] ||= Cart.new)
  #    @cart=Cart.get_cart("cart"+session[:session_id])
  #    #   @cart = Cart.get_cart(session[:cart])
  #    #    puts("cart id: #{@cart.id}")
  #
  #    unless @cart.visable then
  #      @cart.show
  #      respond_to do |format|
  #        format.js if request.xhr?
  #        format.html 
  #      end
  #    end
  #  end
  #
  #  def toggle_cart
  #    find_cart
  #    if @cart.visable then
  #      hide_cart
  #    else
  #      show_cart
  #    end
  #  end
  #    
  #  def get_shopping_cart_item_info 
  #    find_cart
  #    @checkout_cart_item = @cart.items[params[:item_no].to_i]
  #    render :partial=>"/site/shopping_cart_item_info.html", :locals=>{:checkout_cart_item=>@checkout_cart_item}
  #  end
  #  
  #  def get_cart_summary_body 
  #    find_cart
  #    @checkout_cart = @cart
  #    render :partial=>"/site/cart_summary_body.html", :locals=>{:checkout_cart=>@checkout_cart}
  #  end
  #  
  #  def get_cart_contents 
  #    find_cart
  #    @checkout_cart = @cart
  #    render :partial => "checkout_cart_item" , :collection => @checkout_cart.items
  #  end
  #   
  #  def get_shopping_cart_info 
  #    find_cart
  #    render :partial=>"/site/shopping_cart_info.html"
  #  end
  #  
  #  
  #    
  #  def increment_cart_item
  #    find_cart
  #    @current_item_counter=params[:current_item]
  #    @current_item=@cart.items[@current_item_counter.to_i]
  #    @current_item.increment_quantity
  #    @cart.save
  #
  #    if @current_item.quantity > @current_item.product_detail.units_in_stock  then
  #      puts("cart quantity:#{@current_item.quantity }, unit in stock: #{@current_item.product_detail.units_in_stock}")
  #      flash.now[:warning] ='Your request exceeds current inventory, your quantity has been reduced to what we have in stock.'
  #      # @current_item.quantity = @product_detail.units_in_stock.to_i
  #    end
  #    
  #    @flash_message = flash.now[:warning]
  #      
  #    respond_to do |format|
  #      format.json  { head :ok }
  #      format.html { render plain: @flash_message }
  #    end
  #
  #  end
  #
  #  def decrement_cart_item
  #    find_cart
  #    @current_item_counter=params[:current_item]
  #    @current_item=@cart.items[@current_item_counter.to_i]
  #    @current_item.decrement_quantity
  #    if @current_item.quantity == 0 then
  #      @cart.items.delete_at(@current_item_counter.to_i)
  #    end
  #    
  #    @cart.save
  #    respond_to do |format|
  #      format.json  { head :ok }
  #      format.html {render body: nil}
  #    end
  #  end
  #
  #  def delete_cart_item
  #    find_cart
  #    @current_item_counter=params[:current_item]
  #    @current_item=@cart.items.delete_at(@current_item_counter.to_i)
  #    @cart.save
  #
  #    respond_to do |format|
  #      format.json  { head :ok }
  #      format.html {render body: nil}
  #    end
  #  end
  #
  #  def empty_cart
  #    find_cart
  #    @cart.delete
  #    session[:cart] = nil
  #    find_cart
  #    
  #    #    head :ok
  #
  #    #    redirect_to_index
  #
  #    #        find_cart
  #    #    @cart=nil
  #    #    session[:cart] = nil
  #    respond_to do |format|
  #      format.js if request.xhr?
  #      format.html {redirect_to :controller => 'site', :action => 'index'}
  #    end
  #
  #    
  #    def save_order
  #      $hostfull = request.protocol + request.host_with_port
  #
  #   
  #      session[:mainnav_status] = false
  #  
  #      @order = Order.new(params[:order])
  #      @order.add_line_items_from_cart(@cart, $hostfull)
  #      @order.user = User.find_by_id(session[:user_id])
  #      @order.ip_address = request.remote_ip
  #      @order.email = @order.user.name
  #      @order.cart_type="CreditCard"
  #      
  #      if @order.save
  #        return_response=@order.purchase
  #        if return_response.success?
  #          flash[:notice] = "Thank you for your Order!!"
  #          session[:cart] = nil
  #          redirect_to( :action => :success, :controller=>"orders", :id=>@order.id)
  #          #     redirect_to( :action => :customer_detail, :controller=>"orders", :id=>@order.id)
  #
  #        else
  #          flash[:notice] = "Transaction failed! <br> <br> <br>" + return_response.message
  #          render :action => 'checkoutcc'
  #
  #        end
  #
  #        #        session[:cart] = nil
  #        #    redirect_to_index("Thank you for your order")
  #      else
  #        render :action => 'checkoutcc'
  #      end
  #
  #    end
  #
  #  end
  #
  #  
  #  def cart_update
  #    find_cart
  #    
  #    @cart.coupon_code= params[:cart][:coupon_code]
  #    @cart.save
  #    
  #    puts(@cart.inspect)
  #    render plain: params[:cart][:coupon_code]
  #  end
  #  
  #  def load_product_style_slider
  #  
  #    render :partial=>"/site_includes/load_product_style_slider.html", :locals=>{:blah=>"test"}
  #
  #  
  #  end

  def load_asset
    path = params[:path]
    # the_asset = Rails.application.assets.find_asset(path).body rescue ""
    the_asset = ActionController::Base.helpers.compute_asset_path(path) rescue ""
    
    if the_asset == "/"+path then
      the_asset="".dup
    end
    
    render plain: the_asset
  end
  
  def set_time_zone 
    session[:time_zone] = params["time_zone"]
     
    respond_to do |format|
      format.html if params[:value].blank?
      format.json { head :ok }
    end
  end
  
  def update_menu_order
    @user = User.find(session[:user_id])
    # puts(params)
    @user.settings.menu_order = params[:menu_order].split(",")
    
    respond_to do |format|
      format.html if params[:data].blank?
      format.json { head :ok }
    end
  end
  
  def update_menu_shortcuts
    @user = User.find(session[:user_id])
    #  puts(params)
    current_shortcuts = (@user.settings.menu_shortcuts || [] )rescue []
    
    if current_shortcuts.include?(params[:shortcut])
      current_shortcuts.delete(params[:shortcut])
    else
      current_shortcuts << params[:shortcut]
    end
     
    @user.settings.menu_shortcuts = current_shortcuts
    
    respond_to do |format|
      format.html if params[:data].blank?
      format.json { head :ok }
    end
  end
  
  private 
  
  
  #  def find_cart
  #    #  @cart = (session[:cart] ||= Cart.new)
  #    session[:create]=true
  #    
  #    @cart=Cart.get_cart("cart"+session[:session_id]) rescue  Rails.cache.write("cart"+session[:session_id],{}, :expires_in => 15.minutes)
  #    
  #    if not params[:coupon_code].blank? then
  #      puts("Coupon Code Found")
  #      @cart.coupon_code = params[:coupon_code]
  #      @cart.save
  #    end
  #    
  #    #   @cart = Cart.get_cart(session[:cart])
  #    #    session[:cart] = @cart.id
  #  end
  #
  #  def create_menu_lowest_child_list(menu_name, menu_id=nil,with_id=true)
  #    if menu_id.blank? then
  #      if menu_name.blank? then
  #        return []
  #      else
  #        @start_menu = Menu.find_by_name(menu_name)
  #        if @start_menu.blank? then
  #          return "no menu found"
  #        end
  #      end
  #    else
  #      @start_menu = Menu.find(menu_id)
  #    end
  #      
  #    @menus = Menu.find_menu(@start_menu.id)
  #      
  #    return_list = []
  #    @menus.each do |menu|
  #      if menu.menus.size == 0 then
  #        if with_id then
  #          return_list = return_list + [[menu.name, menu.id]]
  #        else
  #          return_list = return_list + [menu.name]
  #        end
  #      else
  #        return_list= return_list + create_menu_lowest_child_list("",menu.id,with_id)
  #      end
  #    end
  #    return return_list
  #  end
    
  def create_menu_lowest_child_list(menu_name, menu_id=nil,with_id=true)
    if menu_id.blank? then
      if menu_name.blank? then
        return []
      else
        @start_menu = Menu.find_by_name(menu_name)
        if @start_menu.blank? then
          return "no menu found"
        end
      end
    else
      @start_menu = Menu.find(menu_id)
    end
      
    @menus = Menu.find_menu(@start_menu.id)
      
    return_list = []
    @menus.each do |menu|
      if menu.menus.size == 0 then
        if with_id then
          return_list = return_list + [[menu.name, menu.id]]
        else
          return_list = return_list + [menu.name]
        end
      else
        return_list= return_list + create_menu_lowest_child_list("",menu.id,with_id)
      end
    end
    return return_list
  end

  def code_mirror
    respond_to do |format|
      format.html { render layout: false} # show.html.erb
    end
  end
  
  
  protected
  
  def authorize
    #   puts "in authorize"
    return true
  end

  def authenticate
    # always create a session.
    session.delete 'init'
    #   puts "in authenticate"

    return true
  end
end

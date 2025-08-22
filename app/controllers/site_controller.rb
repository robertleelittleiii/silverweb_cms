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
    user = User.find_by(id: session[:temp_user_id])

    case user&.effective_multi_factor_type
    when "Authpoint"
      # If the user entered an OTP code, validate it with AuthPoint
      if params[:code].present?
        result = handle_authpoint_otp(user, params[:code])
        # Ensure keys match what cloud.js expects for two-factor form responses
        mapped = {
          message: result[:message],
          sucessfull: result[:success] || result[:sucessfull],
          twofactor: result.key?(:twofactor) ? result[:twofactor] : !result[:success],
          code_expired: !!result[:code_expired],
          uri: result[:uri]
        }
        render json: mapped and return
      else
        # No code provided; fall back to checking push status (if any)
        result = handle_authpoint_authentication(user)
        mapped = {
          message: result[:message],
          sucessfull: result[:success],
          twofactor: result.fetch(:twofactor, true),
          code_expired: result[:code_expired],
          authpoint_pending: result[:authpoint_pending],
          uri: result[:uri]
        }
        render json: mapped and return
      end
    else
      user, twofactor = User.two_factor_auth(params[:code])

      if twofactor
        session[:active] = true
        session[:last_seen] = Time.now
        session[:ip_address] = request.remote_ip rescue "n/a"
        session[:user_id] = user.id
        login_success = true
        flash.now[:notice] = "Login Successful, Welcome!!"
        uri = session[:original_uri]
        session[:original_uri] = nil
        login_sucess = true
        twofactor = false
        code_expired = false
      else
        user = User.find(session[:temp_user_id])
        code_age = ((user.updated_at + user.secret_life) - DateTime.now).round
        if code_age <= 0
          flash.now[:notice] = "Code has expired, please login again."
          code_expired = true
        else
          flash.now[:notice] = "Wrong code, please try again (code expires in #{Time.at(code_age).utc.strftime "%H hr %M min %S sec"})"
        end
        twofactor = true
        login_sucess = true
      end

      respond_to do |format|
        format.json { render json: {
          message: flash[:notice],
          sucessfull: login_success,
          twofactor: twofactor,
          code_expired: code_expired,
          uri: uri
        }}
        format.html { redirect_to(uri || { action: "index" }) }
      end
    end
  end



  #ajax login code
  def login_ajax
    session[:user_id] = nil
    session[:active] = false
    fail_count_max = (Settings.fail_count_max || 3) rescue 3

    user, logged_in, twofactor = User.authenticate(params[:name], params[:password], @results)
    session[:temp_user_id] = user.id unless user.nil?

    if twofactor
      case user.effective_multi_factor_type
      when "Authpoint"
        # Store the plaintext password temporarily for AuthPoint OTP if needed
        session[:authpoint_password] = params[:password]
        ap_init = initiate_authpoint_authentication(user, params[:password])
        authpoint_pending = ap_init[:success]
        authpoint_qrcode = ap_init[:qr_code]
        if authpoint_pending
          # flash is already set inside initiate
        else
          flash.now[:notice] = "AuthPoint authentication could not be initiated. Please try again or contact support."
        end
      when "Text"
        if user.formated_phone_number.present?
          TwilioApi.send_sms(user.formated_phone_number, "Your Security Code is #{user.two_factor_code}")
        end
      when "Email"
        UserNotifier.two_factor_notification(user, $hostfull).deliver
      else
        # None: do nothing
      end
    end

    login_success = false

    if logged_in and not twofactor then
      session[:active] = true
      session[:last_seen] = Time.now
      session[:ip_address] = request.remote_ip rescue "n/a"
      session[:user_id] = user.id
      login_success = true
      flash.now[:notice] = "Login Successful, Welcome!!"
      uri = session[:original_uri]
      session[:original_uri] = nil
    else
      if twofactor
        method = user.effective_multi_factor_type
        comm_method = if method == "Authpoint"
                        "AuthPoint mobile app"
                      elsif method == "Text"
                        user.formated_phone_number.blank? ? "text" : "text"
                      else
                        "email"
                      end
        flash.now[:notice] = "You need to verify your account. Enter code sent to you via #{comm_method}."
      elsif !user.nil? and user.auth_fail_count.to_i >= fail_count_max.to_i
        flash.now[:notice] = "User Account Locked! Too many failed attempts"
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end

    respond_to do |format|
      format.json { render json: {
        message: flash[:notice],
        sucessfull: login_success,
        twofactor: twofactor,
        authpoint_pending: (defined?(authpoint_pending) && authpoint_pending) ? true : false,
        authpoint_qrcode: (defined?(authpoint_qrcode) && authpoint_qrcode.present?) ? authpoint_qrcode : nil,
        uri: uri
      }}
      format.html { redirect_to(uri || { action: "index" }) }
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
      if session[:user_id].present? && session[:active]
        format.json { render json: { exists: true, authenticated: true } }
      elsif session[:temp_user_id].present?
        user = User.find_by(id: session[:temp_user_id])
        if user&.effective_multi_factor_type == "Authpoint"
          authpoint_valid = verify_authpoint_session(user)
          if authpoint_valid
            complete_login(user)
            format.json { render json: { exists: true, authenticated: true } }
          else
            format.json { render json: { exists: true, authenticated: false } }
          end
        else
          format.json { render json: { exists: true, authenticated: false } }
        end
      else
        # Legacy behavior: return exists: true even when unauthenticated to prevent login page refresh loops
        format.json { render json: { exists: true, authenticated: false } }
      end
    end
  end


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
    puts("session[:active]: #{session[:active]}")
    render plain: session[:active] || "false" rescue "false"
  end

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

  private

  def complete_login(user)
    session[:active] = true
    session[:last_seen] = Time.now
    session[:ip_address] = request.remote_ip rescue "n/a"
    session[:user_id] = user.id
    session[:temp_user_id] = nil
    # Clear any temporary AuthPoint password after successful login
    session[:authpoint_password] = nil
    flash.now[:notice] = "Login Successful, Welcome!!"
  end

  def verify_authpoint_session(user)
    return false unless user&.authpoint_session_id

    auth_service = AuthPointService.new(user)
    result = auth_service.verify_authentication
    result[:success]
  end


  def handle_authpoint_authentication(user)
    auth_service = AuthPointService.new(user)
    result = auth_service.verify_authentication

    if result[:success]
      complete_login(user)
      {
        message: result[:message] || "Login Successful, Welcome!!",
        success: true,
        twofactor: false,
        code_expired: false,
        uri: session[:original_uri]
      }
    else
      {
        message: result[:message] || "AuthPoint authentication failed. Please try again.",
        success: false,
        twofactor: true,
        code_expired: result[:status].to_s == 'expired',
        authpoint_pending: result[:status].to_s.upcase == 'PENDING'
      }
    end
  end

  # Handle OTP entry for AuthPoint users during two-factor
  def handle_authpoint_otp(user, code)
    begin
      service = AuthPointService.new(user)
      if user.respond_to?(:authpoint_last_qr_code) && user.authpoint_last_qr_code.present?
        # Responding to a QR Code flow: use qrCodeResponse and /qrcode endpoint with transactionId, no password
        resp = service.authenticate_user(
          user.name,
          'qrcode_response',
          request.remote_ip,
          { qrCodeResponse: code, transactionId: user.authpoint_session_id }
        )
      else
        # Standard OTP flow
        resp = service.authenticate_user(user.name, 'otp', nil, { password: session[:authpoint_password], otp: code })
      end
      status = (resp['status'] || resp['authenticationResult'] || '').to_s.upcase

      case status
      when 'ACCEPTED', 'APPROVED', 'SUCCESS', 'AUTHENTICATED', 'AUTHORIZED'
        complete_login(user)
        {
          message: 'Login Successful, Welcome!!',
          success: true,
          twofactor: false,
          code_expired: false,
          uri: session[:original_uri]
        }
      when 'DENIED', 'REJECTED', 'FAILED'
        { message: 'Invalid code. Please try again.', success: false, twofactor: true, code_expired: false }
      when 'TIMEOUT', 'EXPIRED'
        { message: 'Code has expired, please login again.', success: false, twofactor: true, code_expired: true }
      else
        { message: 'Authentication failed. Please try again.', success: false, twofactor: true, code_expired: false }
      end
    rescue => e
      Rails.logger.error "[AuthPoint] OTP verification error for #{user&.name}: #{e.class}: #{e.message}"
      { message: 'Authentication service temporarily unavailable', success: false, twofactor: true, code_expired: false }
    end
  end


  def initiate_authpoint_authentication(user, password)
    auth_service = AuthPointService.new(user, password)
    begin
      result = auth_service.authenticate

      if result
        if auth_service.last_qr_code.present?
          flash.now[:notice] = "Scan the QR code with the AuthPoint app, then wait on this page."
        else
          flash.now[:notice] = "Please approve the authentication request on your mobile device"
        end
      else
        flash.now[:notice] = "Failed to initiate AuthPoint authentication"
      end
      # Return a small struct-like hash so caller can include QR code when present
      { success: result, qr_code: auth_service.last_qr_code }
    rescue => e
      Rails.logger.error "AuthPoint authentication error: #{e.message}"
      flash.now[:notice] = "Authentication service temporarily unavailable"
      { success: false, qr_code: nil }
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

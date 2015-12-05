class RegistrationController < ApplicationController

  def activate
    $hostfull=request.protocol + request.host_with_port

    @user=User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].nil?
    if @user.nil?

      flash[:notice] = "Your account has already been activated"
      redirect_to :action=>:index, :controller=>:site
    else
      #     if request.post?  
      @user.delete_activation_code
      flash[:notice] = "Account successfully activated for #{@user.name}"
      redirect_to :action=>:index, :controller=>:site
      #     else
      #        render :action => :password_is_reset
      #     end

    end
  end
  
  def testinventory 
    @product_detail = ProductDetail.find(params[:id])
    $hostfull=request.protocol + request.host_with_port

    UserNotifier.inventory_alert(@product_detail, $hostfull).deliver
    redirect_back_or_default(request.referer)

  end
  
  def lostwithemail
    @user = User.find_by_name(params[:name])
    $hostfull=request.protocol + request.host_with_port
    if @user
      if @user.activation_code

        @user.resend_activation_code
        
        UserNotifier.lostwithemail(@user, $hostfull).deliver

        flash[:notice] = "Activation code re-sent to #{@user.name}"
      else
        flash[:notice] = "#{@user.name} has already been activated."
      end
    else
      flash[:notice] = "#{params[:user][:name]} does not exist in system"
    end
    redirect_back_or_default(request.referer)
  end

  def lost
    $hostfull=request.protocol + request.host_with_port

    if request.post?
      @user = User.find_by_name(params[:user][:name])
      if @user
        if @user.activation_code
          @user.resend_activation_code
          flash[:notice] = "Activation code re-sent to #{@user.name}"
        else
          flash[:notice] = "#{@user.name} has already been activated."
        end
      else
        flash[:notice] = "#{params[:user][:name]} does not exist in system"
      end
      redirect_back_or_default('/')
    end
  end
  
  def forgot
    #  @hostfull =
    $hostfull=request.protocol + request.host_with_port
    @hostfull=$hostfull
    if request.post?
      @user = User.find_by_name(params[:user][:name])
      if @user
        @user.create_reset_code
         UserNotifier.reset_notification(@user, $hostfull).deliver
#         UserNotifier.reset_notification2(@user, @hostfull)
        flash[:notice] = "Reset code sent to #{@user.name}"
      else
        flash[:notice] = "#{params[:user][:name]} does not exist in system"
      end
      redirect_back_or_default('/')
    end
  end

  def reset
    @user = User.find_by_password_reset_code(params[:reset_code]) unless params[:reset_code].empty?
    #    @user = User.find_by_password_reset_code(params[:reset_code])
    if @user.nil?
      flash[:notice] ="You already reset your password."
      redirect_to :action=>:forgot
    else
      if request.post?
        if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
          #self.current_user = @user
          @user.delete_reset_code
          flash[:notice] = "Password reset successfully for #{@user.name}"
          redirect_to :controller=>:admin, :action=>:login
        else
          render :action => :reset
        end
      end
    end
  end

  def notify_winner
    @user = User.find_by_name(params[:user])

    $hostfull=request.protocol + request.host_with_port
    user=params[:user]
    UserNotifier.deliver_winner_notification(@user,"", $hostfull)
    flash[:notice] = "Winner Notification sent to #{@user.name}"
    redirect_back_or_default('/')
  end


  def password_is_reset

  end
  
  def register_customer
    session[:main_search_status] = false
    @user = User.new
    @role_name="Customer"
    @new_uri = params[:new_uri] || ""
    puts 'New URI:' + @new_uri
    #     redirect_back_or_default('/')
    session[:original_uri] = @new_uri if not @new_uri==nil
  end

  def register_voter
    @user = User.new
    @role_name="Participant"
    #session[:original_uri] = "/registration/register_voter"

  end

  def register_shop
    @user = User.new
    @role_name="Shop Owner"
    #session[:original_uri] = "/registration/register_shop"

  end

  def register_artist
    @user = User.new
    @role_name="Artist"    
    #session[:original_uri] = "/registration/register_artist"

  end
  
  #  Will perform registration for the new user.  It will
  #  automatically set the role give then invisible field on
  #  the entry form.  Each type of user uses this to register.

  def registration
    session[:main_search_status] = false

    puts"registration"
    uri =  session[:original_uri]
    $hostfull=request.protocol + request.host_with_port

    puts uri
    #first check if user exists.
    @user = User.find_by_name(params[:user][:name])
    @regtype=params[:register][:regtype]||""
    if not @user then
      if request.post? and params[:user]
        @user = User.create(params[:user])
        @role_name = params[:register][:role]
        @role = Role.find_by_name(@role_name)
        @user.roles << @role

        @user_attribute = UserAttribute.create(params[:user_attribute])
        puts(@user_attribute)
        @user.user_attribute = @user_attribute
      
        if @user.save
          @user.create_activation_code
          flash[:notice] = @role_name +" account created."
          session[:user_id] = @user.id
          session[:original_uri] = nil
          redirect_to(uri || { :controller=>"admin", :action => "index"  })
          #redirect_to({ :controller=>"admin", :action => "index"  })
          UserNotifier.signup_notification(@user, $hostfull).deliver

          # redirect_to(:action=> :login,  :name=>@user.name, :password=>@user.password)
          #     redirect_to("/admin/")
          # redirect_to(uri)
        else
          flash[:notice] = @user.errors.full_messages.join("<br>")
          redirect_to("/registration/"+@regtype)
          #redirect_to(uri)
        end
      end

    else
      flash[:notice] = "User already Exists, please try again."
      redirect_to("/registration/"+@regtype)
    end

    #    redirect_to("/admin/")
  end
  #def login
  #    @junk="this is a test"
  #
  #end

  # Had to add this to allow user to either login or do a quick register.  Have kept login in admin for maintanance reasons
  def login
    session[:main_search_status] = false
   
    logger.debug  "in login 1*****************"
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || { :controller=>"admin", :action => "index"  })
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
  end

  private

  # def login (username, password)
  #        @junk="this is a test 2"
  #
  #    session[:main_search_status] = false
  #    logger.debug  "in login 2*****************"
  #
  #    session[:user_id] = nil
  #    if request.post?
  #      user = User.authenticate(username, password)
  #      if user
  #        session[:user_id] = user.id
  #        uri = session[:original_uri]
  #        session[:original_uri] = nil
  #        redirect_to(uri || {:controller=>"admin", :action => "index" })
  #      else
  #        flash.now[:notice] = "Invalid user/password combination"
  #      end
  #    end
  #  end


  protected

  def authorize
    #  session[:original_uri] = request.request_uri


  end

  def authenticate
  end
end

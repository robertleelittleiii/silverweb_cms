class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
 
  def record
		@user = User.find(params[:id])
		@roles = (Role.find(params[:user][:role_ids]) if params[:user][:role_ids])
		@user.roles = (@roles || [])
		if @user.save
      flash[:notice] = "Users roles were successfully updated."
      redirect_to :action => 'view', :id => params[:id]
		else
      flash[:error] = 'There was a problem updating the roles for this user.'
      redirect_to :action => 'view', :id => params[:id]
		end
	end


  def index
    @users = User.all.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.csv { send_data @users.to_csv }

    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    
    
  end

  # POST /users
  # POST /users.xml



  def selfcreate
    puts "selfcreate"

        @user = User.new(user_params)
  end


  def create
    @user = User.new(user_params)
       puts "testing"
      logger.error("controller #{self.class.controller_path}")
      logger.info("action: #{action_name}")
      @newAttributes = UserAttribute.new()

        @user.user_attribute = @newAttributes
        @newAttributes.save()
        
    respond_to do |format|
      if @user.save

        flash[:notice] = "User #{@user.name} was successfully created."
        format.html { redirect_to(:action=>'index') }
        format.xml  { render :xml => @user, :status => :created,
                             :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

 def view
        @user = User.find(params[:id], :include => :roles)
        @roles = Role.all.order(:name)

      respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role }
       end
  end




# def add_attributes
#    @user = User.find(params[:id], :include => :user_attribute)
#    @newAttributes = UserAttribute.create
#    @user.user_attribute = @newAttributes
#    #@user.shop = Shop.create(:name => (@user.name +" Store"))
#    @user.save
#
#   redirect_to :action => 'view_attributes', :id => params[:id]
#
#
# end

  # PUT /users/1
  # PUT /users/1.xml
 def update
    @user = User.find(params[:id])
    if params[:user].keys.first.include?("settings")
      settings_params = params["user"].keys.first.split(".")
      eval("@user." + settings_params[0] + "." + settings_params[1] + "='" + params["user"].values.first + "'" ) rescue ""
      updated = true 
    else
      updated =  @user.update_attributes(params[:user])
    end

    respond_to do |format|
      
      if updated
        flash[:notice] = "User #{@user.name} was successfully updated."
        format.html { redirect_to(:action=>'index') }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
 def destroy
  @user = User.find(params[:id])
  begin
    @user.destroy
      flash[:notice] = "User #{user.name} deleted"
  rescue Exception => e
    flash[:notice] = e.message
  end
  respond_to do |format|
    format.html { redirect_to(users_url) }
    format.xml { head :ok }
  end

end
def view_attributes
       @user = User.find(params[:id], :include => :user_attribute)

      flash[:notice] = "User #{@user.name} has no attributes." if @user.user_attribute.nil?
      respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role }
       end
  end

 def add_attributes
    @user = User.find(params[:id], :include => :user_attribute)
    @newAttributes = UserAttribute.create
    @user.user_attribute = @newAttributes
    #@user.shop = Shop.create(:name => (@user.name +" Store"))
    @user.save

   redirect_to :action => 'view_attributes', :id => params[:id]


 end

  def change_password
    @user = User.find(params[:id])
  end

  def update_password
    @user = User.find(params[:id])

    if params[:user][:password]==params[:user][:password_confirmation] then
      @user.password= params[:user][:password]
      @user.save
    else
      @alert_message= "Password's did not match!!, Password not updated."
end
    
    respond_to do |format|
      format.json { render :json=>{:complete=>"true"}}
      format.html { head :ok} # new.html.erb
    end
  end
  
  def update_roles
    @user = User.find(params[:id])

    if params[:role_id].blank? then
      @roles = Role.all
    else
      @role = Role.find(params[:role_id])
      puts(params[:is_checked])
      if (params[:is_checked]=="true") then
        puts("add to list")
        @user.roles.where(:id=>@role.id).blank? ? @user.roles << @role : ""

      else
        puts("Remove from list")
        @user.roles.delete(@role)
      end
      @user.save
      
    end
    
    respond_to do |format|
      format.html if params[:role_id].blank?
      format.json { head :ok }
    end
  end
  
  def create_empty_record
    @user = User.new
    @user.name = "User_" + Time.now.to_i.to_s + "@someaddress.com"
    @user.password = "password"
    @user.password_confirmation = "password"
    @user.user_attribute = UserAttribute.new
    @user.user_attribute.first_name = "First"
    @user.user_attribute.last_name = "Last"
    @user.user_attribute.save
    @user.save
    
    redirect_to(:controller=>:users, :action=>:edit, :id=>@user.id)
  end
  def delete_ajax
    @user = User.find(params[:id])
    
    if @user.id == session[:user_id] then
      # @user.errors[:base] <<   "Can't delete self."
      render :json => {:error => "Can't delete self."},:status => 400
      puts("can't delete self.")
    else
      @user.destroy
      render :nothing=>true
    end
    
  end
  
  def user_table
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render :layout => false
  end
  
  private

  def current_objects(params={})
    current_page = (params[:start].to_i/params[:length].to_i rescue 0)+1
    role_ids = User.select('users.id').joins(:roles).where("roles.name like '%#{params[:search][:value]}%'").collect(&:id)
    user_attributes_ids = User.select('users.id').joins(:user_attribute).where("user_attributes.last_name like '%#{params[:search][:value]}%' or user_attributes.first_name like '%#{params[:search][:value]}%'").collect(&:id)
    all_ids = User.select('u.id').from("users u").where(conditions).collect(&:id)
    
    @current_objects = User.eager_load(:user_attribute).page(current_page).per( params[:length]).where(:id => (role_ids + all_ids + user_attributes_ids)).includes(:user_attribute).order("#{datatable_columns(params[:order]["0"][:column])} #{params[:order]["0"][:dir]  || "DESC"}") 
    
  end

  def total_objects(params={})
    @total_objects = User.count
  end

  def datatable_columns(column_id)
    puts(column_id)
    case column_id.to_i
    when 0
      return "`users`.`id`"
    when 1
      return "`users`.`name`"
    when 2
      return "`user_attributes`.`first_name`"
    else
      return "`user_attributes`.`last_name`"
    end
  end

  def conditions
    conditions = []
    conditions << "(u.name LIKE '%#{params[:search][:value]}%')" if(params[:search][:value])
    return conditions.join(" AND ")
  end

  private
  
  def user_params
    params[:user].permit( "name", "hashed_password", "salt", "remember_token", "remember_token_expires_at", "activation_code", "activated_at", "state", "deleted_at", "password_reset_code")
  end

end

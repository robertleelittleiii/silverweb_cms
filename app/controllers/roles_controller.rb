class RolesController < ApplicationController

  def index
    @roles = Role.all.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
    end
  end
  def edit
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role }
    end
  end

  def new
    @role = Role.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role }
    end
  end

  def view
    @role = Role.find(params[:id], :include => :rights)
    @rights = Right.all.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role }
    end
  end

  #  def update_rights
  #    @role = Role.find(params[:id], :include => :rights)
  #    @rights = Right.find(:all, :order => :name)
  #
  #    respond_to do |format|
  #      format.html # index.html.erb
  #      format.xml  { render :xml => @role }
  #    end
  #  end
  
  
  def record
    @role = Role.find(params[:id])
    @role.rights.create(params[:right])
    redirect_to :action => 'view', :id => params[:id]
  end

  def record2
		@role = Role.find(params[:id])
		@rights = (Right.find(params[:role][:right_ids]) if params[:role][:right_ids])
		@role.rights = (@rights || [])
		if @role.save
      flash[:notice] = "Roles rights were successfully updated."
      redirect_to :action => 'view', :id => params[:id]
		else
      flash[:error] = 'There was a problem updating the roles for this user.'
      redirect_to :action => 'view', :id => params[:id]
		end
	end

  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role }
    end
  end

  def create
    @role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        flash[:notice] = "role #{@role.name} was successfully created."
        format.html { redirect_to(:action=>'index') }
        format.xml  { render :xml => @role, :status => :created,
          :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def update
    @role = Role.find(params[:id])

    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to(action: "edit", notice: "Role #{@role.name} was successfully updated.") }
        format.json { render :json=> {:notice => "Right #{@role.name} was successfully updated."} }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @role = Role.find(params[:id])
    begin
      @role.destroy
      flash[:notice] = "role #{role.name} deleted"
    rescue Exception => e
      flash[:notice] = e.message
    end
    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml { head :ok }
    end

  end

  def update_rights
    @role = Role.find(params[:id])

    if params[:right_id].blank? then
      @rights = Right.all
    else
      @right = Right.find(params[:right_id])
     # puts(params[:is_checked])
      if (params[:is_checked]=="true") then
     #   puts("add to list")
        @role.rights.where(:id=>@right.id).blank? ? @role.rights << @right : ""

      else
     #   puts("Remove from list")
        @role.rights.delete(@right)
      end
      @role.save
      
    end
    
    respond_to do |format|
      format.html if params[:right_id].blank?
      format.json { head :ok }
    end
  end
  
  
  def create_empty_record
    @role = Role.new
    @role.name = "Role_" + Time.now.to_i.to_s
    @role.save
    
    respond_to do |format|
      format.html {redirect_to(:controller=>:roles, :action=>:edit, :id=>@role.id)}
      format.json { render :json=>@role }
    end
    
  end
  
  def delete_ajax
    @role = Role.find(params[:id])
    @role.destroy
    render body: nil
  end
    
  
  def role_table
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render :layout => false
  end
  
  private

  def current_objects(params={})
    current_page = (params[:start].to_i/params[:length].to_i rescue 0)+1
    @current_objects = Role.page(current_page).per(params[:length]) .order("#{datatable_columns(params[:order]["0"][:column])} #{params[:order]["0"][:dir]  || "DESC"}").where(conditions)
      
  end
  
  
  def total_objects(params={})
    @total_objects = Role.count
  end

  def datatable_columns(column_id)
  #  puts(column_id)
    case column_id.to_i
    when 0
      return "`roles`.`id`"
    else
      return "`roles`.`name`"
    end
  end

  def conditions
    conditions = []
    conditions << "(roles.name LIKE '%#{params[:search][:value]}%')" if(params[:search][:value])
    return conditions.join(" AND ")
  end
 
  
  private

  
  def role_params
    params[:role].permit( "name")
  end
  
end

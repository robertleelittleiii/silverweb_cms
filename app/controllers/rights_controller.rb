class RightsController < ApplicationController

  def index
    @rights = Right.all.order(:name)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rights }
    end
  end
  def edit
    @right = Right.find(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @right }
    end
  end

  def new
    @right = Right.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @right }
    end
  end

  def show
    @right = Right.find(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @right }
    end
  end

  def create
    @right = Right.new(right_params)

    respond_to do |format|
      if @right.save
        flash[:notice] = "Right #{@right.name} was successfully created."
        format.html { redirect_to(:action=>'index') }
        format.xml  { render :xml => @right, :status => :created,
          :location => @right }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @right.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def update
    @right = Right.find(params[:id])

      respond_to do |format|
      if @right.update_attributes(right_params)
        format.html { redirect_to(action: "edit", notice: "Right #{@right.name} was successfully updated.") }
        format.json { render :json=> {:notice => "Right #{@right.name} was successfully updated."} }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @right.errors,
          :status => :unprocessable_entity }
      end
    end
  end
  
  def update_actions
    @right = Right.find(params[:id])
    @action_list = ["*"] + @right.action.to_s.split(",") + ((@right.controller + "_controller").camelize.constantize.action_methods).to_a
    @action_list.uniq!
    
    respond_to do |format|
      format.html 
      format.json { head :ok }
    end
  end

  def destroy
    @right = Right.find(params[:id])
    begin
      @right.destroy
      flash[:notice] = "Right #{right.name} deleted"
    rescue Exception => e
      flash[:notice] = e.message
    end
    respond_to do |format|
      format.html { redirect_to(rights_url) }
      format.xml { head :ok }
    end

  end

  def create_empty_record
    @right = Right.new
    @right.name = "Right_" + Time.now.to_i.to_s
    @right.save
    
    respond_to do |format|
      format.html {redirect_to(:controller=>:rights, :action=>:edit, :id=>@right.id)}
      format.json { render :json=>@right }
    end
    
  end
  
  def delete_ajax
    @right = Right.find(params[:id])
    @right.destroy
    render :nothing=>true
  end
    
  
  def right_table
    @controllers = []
    routes= Rails.application.routes.routes.map do |route|
      @controllers = (@controllers << route.defaults[:controller]).uniq 
    end
    
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render :layout => false
  end
  
  private

  def current_objects(params={})
    current_page = (params[:start].to_i/params[:length].to_i rescue 0)+1
    @current_objects = Right.page(current_page).per(params[:length]) .order("#{datatable_columns(params[:order]["0"][:column])} #{params[:order]["0"][:dir]  || "DESC"}").where(conditions)
      
  end
  
  
  def total_objects(params={})
    @total_objects = Right.count
  end

  def datatable_columns(column_id)
    puts(column_id)
    case column_id.to_i
    when 0
      return "`rights`.`id`"
    when 1
      return "`rights`.`name`"
    when 2
      return "`rights`.`controller`"
    else
      return "`rights`.`action`"
    end
  end

  def conditions
    conditions = []
    conditions << "(rights.name LIKE '%#{params[:search][:value]}%' or
          rights.controller LIKE '%#{params[:search][:value]}%' or
          rights.action LIKE '%#{params[:search][:value]}%'
       )" if(params[:search][:value])
    return conditions.join(" AND ")
  end
 
  
  
  def right_params
    params[:right].permit( "name", "controller", "action")
  end

end

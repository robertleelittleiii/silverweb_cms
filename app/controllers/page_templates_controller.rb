class PageTemplatesController < ApplicationController
  
  #uses_tiny_mce(:options => AppConfig.full_mce_options, :only => [:new, :edit])

  
  
  # GET /page_templates
  # GET /page_templates.json
  def index
    session[:mainnav_status] = true

    @page_templates = PageTemplate.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json=>@page_templates} 
    end
  end

  # GET /page_templates/1
  # GET /page_templates/1.json
  def show
    @page_template = PageTemplate.find(params[:id])

    respond_to do |format|
      format.html { render :layout=>"template.html"} # show.html.erb
      format.json { render :json=>@page_template }
    end
  end

  # GET /page_templates/new
  # GET /page_templates/new.json
  def new
    @page_template = PageTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json=>@page_template}
    end
  end

  # GET /page_templates/1/edit
  def edit
    session[:mainnav_status] = true

    @page_template = PageTemplate.find(params[:id])
    
    @page_template.revert_to(params[:version].to_i) if params[:version]
    
    respond_to do |format|
      format.html 
      format.json  { render :json => @page_template, :status => :created, :location => @page_template }
    end
  end

  # POST /page_templates
  # POST /page_templates.json
  def create
    @page_template = PageTemplate.new(page_template_params)

    respond_to do |format|
      if @page_template.save
        format.html { redirect_to @page_template, :notice=>"Page template was successfully created." }
        format.json { render :json=>@page_template, :status=>:created, :location=>@page_template }
      else
        format.html { render :action=>"new" }
        format.json { render :json=>@page_template.errors, :status=>"unprocessable_entity" }
      end
    end
  end

  # PUT /page_templates/1
  # PUT /page_templates/1.json
  def update
    @page_template = PageTemplate.find(params[:id])

    respond_to do |format|
      if @page_template.update(page_template_params)
        format.html { redirect_to(:action =>"edit", :notice => 'Page Template was successfully updated.') }
        format.json { render :json=> {:notice => 'Page Template was successfully updated.'} }
      else
        format.html { render :action=>"edit" }
        format.json { render :json=>@page_template.errors, :status=>"unprocessable_entity" }
      end
    end
  end

  # DELETE /page_templates/1
  # DELETE /page_templates/1.json
  def destroy
    @page_template = PageTemplate.find(params[:id])
    @page_template.destroy

    respond_to do |format|
      format.html { redirect_to page_templates_url }
      format.json { head :ok }
    end
  end
  
  # CREATE_EMPTY_RECORD /page_templates/1
  # CREATE_EMPTY_RECORD /page_templates/1.json

  def create_empty_record
    @page_template = PageTemplate.new
    @page_template.title="new template"
    @page_template.description= "new template description"
    @page_template.save
    
    redirect_to(:controller=>:page_templates, :action=>:edit, :id=>@page_template)
  end

  
  def page_template_table
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render :layout => false
  end
  
  def insert 
        @page_template = PageTemplate.find(params[:id])

  end
  
  private
  def current_objects(params={})
    current_page = (params[:start].to_i/params[:length].to_i rescue 0)+1
    @current_objects = PageTemplate.page(current_page).per(params[:length]).order("#{datatable_columns(params[:order]["0"][:column])} #{params[:order]["0"][:dir]  || "DESC"}").where(conditions(params))
  end
  

  def total_objects(params={})
    @total_objects = PageTemplate.where(conditions(params)).count()
  end

  def datatable_columns(column_id)
   # puts(column_id)
    case column_id.to_i
    when 0
      return "`page_templates`.`id`"
    when 1
      return "`page_templates`.`title`"
    else
      return "`page_templates`.`body`"
    end
  end

      
  def conditions(params={})
    
    conditions = []
   
    conditions << "(page_templates.id LIKE '%#{params[:search][:value]}%' OR
       page_templates.title LIKE '%#{params[:search][:value]}%' OR 
       page_templates.body LIKE '%#{params[:search][:value]}%')" if(params[:search][:value])
    return conditions.join(" AND ")
    
    
  end
  
  def page_template_params
    params[:page_template].permit( "title", "description", "body")
  end
end

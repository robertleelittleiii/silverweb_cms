class PageTemplatesController < ApplicationController
  
  uses_tiny_mce(:options => AppConfig.full_mce_options, :only => [:new, :edit])

  
  
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

  end

  # POST /page_templates
  # POST /page_templates.json
  def create
    @page_template = PageTemplate.new(user_attribute_params)

    respond_to do |format|
      if @page_template.save
        format.html { redirect_to @page_template, :notice=>"Page template was successfully created." }
        format.json { render :json=>@page_template, :status=>:created, :location=>@page_template }
      else
        format.html { render :action=>"new" }
        format.json { render :json=>@page_template.errors, :status=>:unprocessable_entry }
      end
    end
  end

  # PUT /page_templates/1
  # PUT /page_templates/1.json
  def update
    @page_template = PageTemplate.find(params[:id])

    respond_to do |format|
      if @page_template.update_attributes(user_attribute_params)
        format.html { redirect_to(:action =>"edit", :notice => 'Page Template was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action=>"edit" }
        format.json { render :json=>@page_template.errors, :status=>"unprocessable_entry" }
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
    @page_template.save
    
    redirect_to(:controller=>:page_templates, :action=>:edit, :id=>@page_template)
  end

  def template_list
    @page_templates = PageTemplate.order(:title)
    
    @last_page_template = @page_templates.last
  end
  
  private
  
  def page_template_params
    params[:page_template].permit( "title", "description", "body")
  end
end

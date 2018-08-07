class PagesController < ApplicationController  
  # GET /pages
  # GET /pages.json

  # uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:new, :edit])
  # uses_tiny_mce(:options => AppConfig.full_mce_options, :only => [:new, :edit])

  STYLE_TYPES = [["B L A N K",""],["Agriculture","agriculture"],["Marine","marine"],["Automotive","automotive"], ["Industrial","industrial"],["Do it yourself","doityourself"],["Trades","trades"] ]
  TEMPLATE_TYPES = [["B L A N K",""],["Home Page","home"],["Infomation Slider","slider"],["Tell Your Story","tell-your-story"]]

  protect_from_forgery except: :link_list
  
  def index
    session[:mainnav_status] = true
    @pages = Page.all

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    session[:mainnav_status] = true
    session[:current_page] = params[:id]
    
   
    @page = Page.find(params[:id])
    @page.revert_to(params[:version].to_i) if params[:version]
    @style_type = [] # []STYLE_TYPES
    @template_types = [] # TEMPLATE_TYPES
    
   # paths = ActionController::Base.view_paths.map{|i| (i.to_path.include?("silverweb") ? i.to_path : "")}.delete_if(&:empty?)
    paths = ActionController::Base.view_paths
    template_types = [["B L A N K",""]]
    paths.each do |the_view_path|
      templates = Dir.glob(the_view_path.to_path+ "/site/show_page*")
      
      templates.each do |template|
        template_name = template.split("/").last.split("-").drop(1).join("-").split(".").first
        template_types << [template_name + " Template",template_name] if not template_name.blank?
      end
    end
    
    @template_types = template_types
    
    #paths to style_type CSS files.
    
    style_types = []

    style_path = Rails.root.to_s + "/app/assets/stylesheets" +  "/style_types/*"
    style_type_files =  Dir.glob(style_path)
    puts(style_type_files)
    
    style_type_files.each do |style_type|
       css_file_name = style_type.split("/").last
       style_types << [css_file_name.split(".").first.humanize + " Style",css_file_name] if not css_file_name.blank?
    end
        
    @style_type = [["B L A N K",""]] + style_types if style_types.length >0

    puts("New TemplateList:#{ template_types.inspect}")
    
    @item_edit =  @page
    @menu_location=[["Top",1] , ["Side",2]]
    
    
    respond_to do |format|
      format.html 
      format.json  { render :json => @page, :status => :created, :location => @page }
    end
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        format.html { redirect_to(@page, :notice => 'Page was successfully created.') }
        format.json  { render :json => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(page_params)
        format.html { redirect_to(:action =>"edit", :notice => 'Page was successfully updated.') }
        format.json { render :json=> {:notice => 'Page was successfully updated.'} }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.json  { head :ok }
    end
  end


  def create_empty_record
    @page = Page.new
    @page.title="New Page"
    @page.body="Edit Me"
    @page.full_screen=false
    @page.slider_show_nav = true

    @page.save
    redirect_to(:controller=>"pages", :action=>"edit", :id=>@page)
  end

  def get_sliders_list
        @page = Page.find(params[:page_id])
        render :partial=>"slider_list.html", :collection=>@page.sliders
  end
  
  def update_checkbox_tag
    @page=Page.find(params[:id])
    @tag_name=params[:tag_name] || "tag_list"
    # truely toggle the value
    
    if @page.send(@tag_name).include?(params[:field]) then
      @page.send(@tag_name).remove(params[:field])
    else
      @page.send(@tag_name).add(params[:field])
    end
    

    @page.save

    render(:nothing => true)

  end
  
 def page_table
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render :layout => false
  end
  
 
  def delete_ajax
      @page = Page.find(params[:id])
    
      @page.destroy
      render :nothing=>true
    end
    
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
 
  
  private

  def current_objects(params={})
    current_page = (params[:start].to_i/params[:length].to_i rescue 0)+1
    @current_objects = Page.page(current_page).per(params[:length]).order("#{datatable_columns(params[:order]["0"][:column])} #{params[:order]["0"][:dir]  || "DESC"}").where(conditions(params))
  end
  

  def total_objects(params={})
    @total_objects = Page.where(conditions(params)).count()
  end

  def datatable_columns(column_id)
    puts(column_id)
    case column_id.to_i
    when 0
      return "`pages`.`id`"
    when 1
      return "`pages`.`title`"
    else
      return "`pages`.`body`"
    end
  end

      
  def conditions(params={})
    
    conditions = []
   
    conditions << "(pages.id LIKE '%#{params[:search][:value]}%' OR
       pages.title LIKE '%#{params[:search][:value]}%' OR 
       pages.body LIKE '%#{params[:search][:value]}%')" if(params[:search][:value])
    return conditions.join(" AND ")
    
    
  end
  

def page_params
  params[:page].permit( "title", "body", "in_menu", "menu_local", "full_screen", "has_slider", "slider_height", "slider_width", "meta_description", "meta_keywords", "meta_robot", "template_name", "secure_page", "dialog_width", "dialog_height", "slider_show_nav", "page_style","page_table", "slug")
end
end
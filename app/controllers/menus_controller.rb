class MenusController < ApplicationController
  # GET /menus
  # GET /menus.json
  # uses_tiny_mce(:options => AppConfig.full_mce_options.merge({:width=>"897px"}), :only => [:new, :edit])

  # MENU_TYPES = [["none",3],["page",1] , ["html",2], ["link",4], ["action",5]]
  #  ACTION_TYPES = [["none",0],["Product Category",1],["Product Category with Subs",2],["Product Category with Page",3],["Product Category Skip Dept",4] ]
  #  ACTION_TYPES = [["none",0],["Product Category",1],["Product Category with Subs",2],["Product Category with Page",3],["Product Category Skip Dept",4], ["Service Passes",5], ["Gift Cards",6] ]
  # ACTION_TYPES = [["none",0],["Product Category",1],["Product Category with Page",3], ["Gift Cards",6] ]
  
  CUSTOM_PAGES = [["none",""],["Mix & Match","show_products_with_page_mm"]]

  
  def index 
    session[:mainnav_status] = true
    @menus = Menu.find_root_menus()

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @menus }
    end
  end

  # GET /menus/1
  # GET /menus/1.json
  def show
    @menu = Menu.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @menu }
    end
  end

  # GET /menus/new
  # GET /menus/new.json
  def new
    @menu = Menu.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @menu }
    end
  end

  # GET /menus/1/edit
  def edit
    session[:mainnav_status] = true
    @menu = Menu.find(params[:id])
    @item_edit =  @menu
    @menu_type= SilverwebCms::Config.MENU_TYPES
    @action_type= SilverwebCms::Config.ACTION_TYPES
    @page_templates = CUSTOM_PAGES
    @partial_action = SilverwebCms::Config.ACTION_TYPES[@menu.rawhtml.to_i][0].gsub(" ","_").downcase + "_type.html" rescue   ""
      
    all_pages = Page.all
    @page_list= [["N O N E (select to clear)",""]]+ all_pages.collect {|e| [e.title, e.id]}
    @image = @menu.pictures.new

  end

  # POST /menus
  # POST /menus.json
  def create
    @menu = Menu.new(params[:menu])

    respond_to do |format|
      if @menu.save
        format.html { redirect_to(@menu, :notice => 'Menu was successfully created.') }
        format.json  { render :json => @menu, :status => :created, :location => @menu }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @menu.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /menus/1
  # PUT /menus/1.json
  def update
    @menu = Menu.find(params[:id])

    respond_to do |format|
      if @menu.update_attributes(menu_params)
        format.html { redirect_to(:action =>"edit", :notice => 'Menu was successfully updated.') }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @menu.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /menus/1
  # DELETE /menus/1.json
  def destroy

    @menu = Menu.find(params[:id])
    @menu.destroy
    @menus = Menu.find_root_menus()
    render :nothing => true

    #render :update do |page|
    # page.replace_html "menu-item-list",{ :partial =>'menu_list.html', :collection=>@menus}
    # page.hide "menu-item-list"
    # end
  end

  def create_empty_record

    type = params[:typeofrecord]
    parent_id = params[:parent_id]
    #   @parent_menu = Menu.find(parent_id)
    @menu = Menu.new
    @menu.name="New Menu :" + type + " " + (Menu.all.count + 1).to_s
    @menu.m_type="1"
    @menu.menu_active=true
    @menu.parent_id=parent_id

    if parent_id=="0" then
    else
      @parent_menu=Menu.find(parent_id)
      @menu.m_order=@parent_menu.menus.count+1
    end


    if @menu.save then
      respond_to do |format|
        @menus = Menu.find_root_menus()
        if parent_id == "0" then
          format.html {render :partial =>'menu_list.html', :collection=>@menus}
        else
          format.html {render  :partial =>'menu_list.html', :collection=>@parent_menu.menus}
        end
      end
          
    end
    #    if @menu.save then
    #      @menus = Menu.find_root_menus()
    #      render :update do |page|
    #        if parent_id == "0" then
    #          page.replace_html "menu-item-list",{ :partial =>'menu_list.html', :collection=>@menus}
    #          page.call "bindToggleListClick" 
    #        else
    #          page.replace_html "sortable_"+@parent_menu.id.to_s,{ :partial =>'menu_list.html', :collection=>@parent_menu.menus}
    #          page.call "addHasChildren", "#field_"+@parent_menu.id.to_s
    #          page.call "bindToggleListClick" , "#sortable_"+@parent_menu.id.to_s
    #          #page.hide "menu-item-list"
    #        end
    #        page.call "makeDraggable"
    #        page.call "bindDeleteMenu"
    #      end
    #    end
  end

  def update_order
    puts("here")
    puts(params)
    paramName="field"
    #paramName=params[:name]
    params[paramName].each_with_index do |id, position|
      Menu.update(id, :m_order => position)
    end
    render :nothing => true

  end
  
  def ajax_load_partial
  
    @menu = Menu.find(params[:id])
    @item_edit =  @menu
    @menu_type= SilverwebCms::Config.MENU_TYPES
    @action_type= SilverwebCms::Config.ACTION_TYPES
    @page_templates = CUSTOM_PAGES

    all_pages = Page.all
    @page_list=all_pages.collect {|e| [e.title, e.id]}
    # render :update do |page|
    #   page.replace_html "menu-options", :partial =>params[:partial_type] + "_type.html"
    # end
    
    # render :partial=>params[:partial_type] + "_type.html"

    # "this is a test"
    name = params[:partial_type].gsub(" ","_")
    #  render_to_string :partial=>(params[:partial_type] + "_type.html")
    #begin
      render :partial=>(name.downcase + "_type.html") 
    #rescue 
    #  render :text=>""
    # =>  end
    # render :nothing=>true


    #  render :update do |page|
    #       page.replace_html "menu-options",{ :partial =>(params[:partial_type] + "_type.html")}
    #  end
  end

  
  def add_image
    @menu = Menu.find(params[:id])
    format = params[:format]
    image=params[:image]
    if image.size > 0
      @picture = Picture.new(:image=>image)
      @picture.position=999
      image_saved = @picture.save
      @menu.pictures<< @picture
    end
  
    respond_to do |format|
      if image_saved
        format.js   { render :action=>"../pictures/create.js" }
        format.html { redirect_to @picture, :notice=>"Picture was successfully created." }
        format.json { render :json=>@picture, :status=>:created, :location=>@picture }
      else
        format.html { render :action=>"new" }
        format.json { render :json=>@picture.errors, :status=>:unprocessable_entry }
      end
    end
    
#    respond_to do |format|
#      flash[:notice] = 'Picture was successfully added.'
#      format.js do
#          render :update do |page|
#            page.replace_html("images" , :partial => "/images/images" , :object => @menu.pictures)
#            if @menu.pictures.count > 0
#              page.hide "imagebutton"
#            end
#            page.hide "loader_progress"
#            page.show "upload-form"
#            
#            #           page.call("jQuery('#loader_progress').toggle();")
#            #           page.call("jQuery('#upload-form').toggle();")
#            page.visual_effect :highlight, "image_#{@image.id}"
#            page[:images].show if @menu.pictures.count == 1
#        end
#      end
#
#      format.html { redirect_to :action => 'show', :id => params[:id] }
#    end
  end

  
  def delete_ajax
      @menu = Menu.find(params[:id])
    
      @menu.destroy
      render :nothing=>true
    end
    
  
  def delete_image
    @menu = Menu.find(params[:incoming_id])
    @image = Picture.find(params[:id])
    @image.destroy
    
    #  respond_to do |format|  
    #          format.html { render :nothing => true }
    #          format.js   { render :nothing => true }  
    #  end  

    
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to :action => 'show', :id=>params[:menu_id]}
    end
  end


  def destroy_image
    @image = Picture.find(params[:id])
    @image.destroy
    redirect_to :action => 'show', :id => params[:menu_id]
  end

  def update_image_order
    params[:album].each_with_index do |id, position|
      #   Image.update(id, :position => position)
      Picture.reorder(id,position)
    end
    render :nothing => true

  end


  def update_menu_list
    session[:mainnav_status] = true
    @menus = Menu.find_root_menus()

    respond_to do |format|
      format.html  {render :partial=>"menu_list.html", :collection=>@menus}
      format.json  { render :json => @menus }
    end
  end  
  
  def render_menu_list
    @menus = Menu.where(:id=> params[:menu_id])
    session[:mainnav_status] = true
    respond_to do |format|
      format.html  {render :partial=>"menu_list.html", :collection=>@menus}
      format.json  { render :json => @menus }
    end

  end
  
  def render_menu
    @menus = Menu.where(:id=> params[:menu_id]).first
    @menu_helper = params[:menu_helper]
    @menu_params = JSON.parse(params[:menu_params]).symbolize_keys
    
    respond_to do |format|
      format.html  {render :partial=>"/menus/helper_render/" + @menu_helper}
      format.json  { render :json => @menus }
    end
  end


  private
  def menu_params
    params[:menu].permit( "name", "page_id", "parent_id", "has_submenu", "m_order", "m_type", "rawhtml", "url", "has_image", "menu_active", "template")
  end


end

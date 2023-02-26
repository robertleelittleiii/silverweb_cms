class SlidersController < ApplicationController
  # uses_tiny_mce(:options => AppConfig.full_mce_options, :only => [:new, :edit])
  
  BUTTON_COLOR_LIST = [["yellow","yellow-button"],["grey","grey-button"] , ["red","red-button"], ["blue","blue-button"]]


  # GET /sliders
  # GET /sliders.json
  def index
    @sliders = Slider.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json=>@sliders} 
    end
  end

  # GET /sliders/1
  # GET /sliders/1.json
  def show
    @slider = Slider.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json=>@slider }
    end
  end

  # GET /sliders/new
  # GET /sliders/new.json
  def new
    @slider = Slider.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json=>@slider}
    end
  end

  # GET /sliders/1/edit
  def edit
    @button_color_list = BUTTON_COLOR_LIST
    @page_list = Page.all.collect {|e| [e.title, e.title]}
    
        session[:mainnav_status] = true

    @slider = Slider.find(params[:id])
    session[:current_page] = @slider.page.id

  end

  # POST /sliders
  # POST /sliders.json
  def create
    @slider = Slider.new(slider_params)

    respond_to do |format|
      if @slider.save
        format.html { redirect_to @slider, :notice=>"Slider was successfully created." }
        format.json { render :json=>@slider, :status=>:created, :location=>@slider }
      else
        format.html { render :action=>"new" }
        format.json { render :json=>@slider.errors, :status=>:unprocessable_entity }
      end
    end
  end

  # PUT /sliders/1
  # PUT /sliders/1.json
  def update
    @slider = Slider.find(params[:id])

    respond_to do |format|
      if @slider.update(slider_params)
        format.html { redirect_to(:action=>"edit", :notice=>"Slider was successfully updated.")}
        format.json { head :ok }
      else
        format.html { render :action=>"edit" }
        format.json { render :json=>@slider.errors, :status=>"unprocessable_entity" }
      end
    end
  end

  # DELETE /sliders/1
  # DELETE /sliders/1.json
  def destroy
    @slider = Slider.find(params[:id])
    @slider.destroy

    respond_to do |format|
      format.html { head :ok }
      format.json { head :ok }
    end
  end
  
  # CREATE_EMPTY_RECORD /sliders/1
  # CREATE_EMPTY_RECORD /sliders/1.json

  def create_empty_record
    @page = Page.find(params[:page_id]) || ""
    
    
    @slider = Slider.new
    @slider.page_id = params[:page_id] || ""
    @slider.slider_name = "Untitled Slider" + (@page.sliders.count + 1).to_s
    @slider.slider_order = @page.sliders.count + 1
    @slider.slider_type = 0
    @slider.slider_content = "Edit Me"
    @slider.save
    
    redirect_to(:controller=>:sliders, :action=>:edit, :id=>@slider, :notice=>"Slider was successfully created.")
  end

  def sort
    @sliders = Slider.where(:page_id=>params[:page_id])
    @sliders.each do |slider|
      slider.slider_order = params['slider'].index(slider.id.to_s) + 1
    #  puts(slider.slider_order, slider)
      slider.save
    end

    render body: nil
  end
  private
  
  def slider_params
    params[:slider].permit("page_id", "slider_order", "slider_name", "slider_active", "slider_type", "slider_content","slider_url", "slider_tag_line_one", "slider_tag_line_two", "slider_button_color")
  end
end

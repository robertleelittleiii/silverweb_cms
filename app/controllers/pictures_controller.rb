class PicturesController < ApplicationController
  # GET /pictures
  # GET /pictures.json
  def index
    @pictures = Picture.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json=>@pictures} 
    end
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
    @picture = Picture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json=>@picture }
    end
  end

  # GET /pictures/new
  # GET /pictures/new.json
  def new
    @picture = Picture.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json=>@picture}
    end
  end

  # GET /pictures/1/edit
  def edit
    @picture = Picture.find(params[:id])
  end

  def insert
    @picture = Picture.find(params[:id])
  end
  
  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(picture_params)

    respond_to do |format|
      if @picture.save
        format.js   { render :action=>"create" }
        format.html { redirect_to @picture, :notice=>"Picture was successfully created." }
        format.json { render :json=>@picture, :status=>:created, :location=>@picture }
      else
        format.html { render :action=>"new" }
        format.json { render :json=>@picture.errors, :status=>:unprocessable_entry }
      end
    end
  end

  # PUT /pictures/1
  # PUT /pictures/1.json
  def update
    @picture = Picture.find(params[:id])

    respond_to do |format|
      if @picture.update_attributes(picture_params)
        format.html { redirect_to @picture, :notice=>"Picture was successfully updated."}
        format.json { head :ok }
      else
        format.html { render :action=>"edit" }
        format.json { render :json=>@picture.errors, :status=>"unprocessable_entry" }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    @picture = Picture.find(params[:id])
    @picture.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to pictures_url }
      format.json { head :ok }
    end
   
  end
  
  # CREATE_EMPTY_RECORD /pictures/1
  # CREATE_EMPTY_RECORD /pictures/1.json

  def create_empty_record
    @picture = Picture.new
    @picture.save
    
    redirect_to(:controller=>:pictures, :action=>:edit, :id=>@picture)
  end
  
  
  def search 
    @search = params[:searchTerm]
    
    @pictures = !params[:id].blank? ? Picture.by_search_term(@search).where(:resource_id=>params[:id], :resource_type=>params[:type]).order(created_at: :desc) : Picture.by_search_term(@search).order(created_at: :desc)

    if @pictures.blank? then
      render plain: "Nothing found, please try again!"
    else
      render :partial=>"/pictures/picture_list.html"
    end
  end
  
  
  def render_picture
    class_name =  params[:class_name]

    @picture = Picture.where(id: params[:id]).first
    if class_name.blank? then
      render :partial=>"/pictures/picture_view.html" 
    else
      render :partial=> class_name.downcase + "s" + "/picture_view.html" 
    end
  end
  
  def render_pictures
    class_name =  params[:class_name]
  
    @pictures = class_name.classify.constantize.where(id: params[:id]).first.pictures.order(created_at: :desc)

    if class_name.blank? then
      render(:partial=>"/pictures/picture_list.html", locals: {picture_list: @pictures} )
    else
      render(:partial=> class_name.downcase + "s" + "/picture_list.html", locals: {picture_list: @pictures} )
    end
    
  end
  
  def download_file
    @picture = Picture.find(params[:id])
    send_file(@picture.image.path,
      :disposition => 'image',
      :url_based_filename => false)
  end
  
  def insert_image
    @picture = Picture.find(params[:id])
    @image_class_list =  [["Original Size",nil]] + ImageUploader.versions.keys.map{|item| [(item.to_s.humanize), item] } 

    
  end
  
  
  private

  def picture_params
    params[:picture].permit( "title", "description", "position", "image", "resource_id", "resource_type", "active_flag")
  end
  
end

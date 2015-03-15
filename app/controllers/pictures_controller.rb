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
  
  
  def render_picture
    @picture = Picture.where(id: params[:id]).first
    render :partial=>"/pictures/picture_view.html"   
  end
  
  
  def download_file
    @picture = Picture.find(params[:id])
    send_file(@picture.image.path,
      :disposition => 'image',
      :url_based_filename => false)
  end
  
    private

def picture_params
  
  params[:picture].permit( "title", "description", "position", "image", "resource_id", "resource_type")
end
  
end

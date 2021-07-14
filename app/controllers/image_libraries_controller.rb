class ImageLibrariesController < ApplicationController
  
  def image_list
    @pictures = Picture.all.order(created_at: :desc).limit(50)
    session[:page]=1
    respond_to do |format|
      format.html # image_list.html.erb
      format.xml  { render xml: @pictures}
      format.json { render json: @pictures}
    end
  end
  
  def next_images
    session[:page] = session[:page] + 1
    @pictures = Picture.page(session[:page]).per(50).order(created_at: :desc).limit(50)
    respond_to do |format|
      format.html # image_list.html.erb
      format.xml  { render xml: @pictures}
      format.json { render json: @pictures}
    end
  end
  
  
  
end
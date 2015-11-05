class ImageLibrariesController < ApplicationController
  
  def image_list
    @pictures = Picture.all.order(created_at: :desc)
    
     respond_to do |format|
      format.html # image_list.html.erb
      format.xml  { render xml: @users}
      format.json { render json: @users}
    end
  end
  
  
  
  
  
end
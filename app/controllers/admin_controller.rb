class AdminController < ApplicationController
  # just display the form and wait for user to
  # enter a name and password

  protect_from_forgery except: :clear_user_locks

  def login
    
    fail_count_max = (Settings.fail_count_max || 3) rescue 3

  
    admin_params
    session[:user_id] = nil
    if request.post?
      user, logged_in, twofactor = User.authenticate(params[:name], params[:password])
      if logged_in
        session[:user_id] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || { :action => "index" })
      else
        if user.auth_fail_count.to_i >= fail_count_max
          flash.now[:notice] = "User Account Locked! Too many failed attempts. Reset Password or Contact System Administrator."
        else
          flash.now[:notice] = "Invalid user/password combination"
        end
      end
    end
  end


  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:controller=>:site, :action => "index")
  end


  def user_administration

  
  
    respond_to do |format|
      format.html
      format.json  { head :ok }
    end  
    
  end

  
  def index
    @user =  User.where(:id=>session[:user_id]).includes(:user_attribute).first
    @user_attributes = @user.user_attribute
    if @user.user_attribute.nil? then
     
      @newAttributes = UserAttribute.create

      @user.user_attribute = @newAttributes
    
      #@user.shop = Shop.create(:name => (@user.name +" Store"))
      @user.save
 
    end
    session[:mainnav_status] = true

  end
  
  def edit_ajax   
    admin_params

    if params[:pointer_class]=="UserAttribute" then
      @user = UserAttribute.find(params[:id])
    else
      @user = User.find(params[:id])
    end
    render :update do |page|
      page.replace_html "field_"+params[:field], :partial =>'edit_ajax.html'
    end
    # render(:layout=>false)
  end

  def cancel_ajax
    admin_params

    if params[:pointer_class]=="UserAttribute" then
      @user = UserAttribute.find(params[:id])
    else
      @user = User.find(params[:id])
    end
    @field=params[:field]
    render :update do |page|
      page.replace_html "field_"+params[:field], :partial =>'cancel_ajax.html'
    end
  end

  def update_ajax
    admin_params

    @alert_message="".dup
    if params[:pointer_class]=="UserAttribute" then
      @user = UserAttribute.find(params[:id])
      @user[params[:field]] = params[params[:field]]
      @user.save
    else
      @user = User.find(params[:id])
      # Note:  we must force this to be non generic for password to "kick off"  code in user object to set password params.
      if params[:field]=="password"
        if params[:password]==params["password_check"] then
          @user.password= params[:password]
        else
          #render(:update)
          @alert_message= "Password's did not match!!, Password not updated."
          #    flash.now[:notice] = "Password's didn't match!!, Password not updated"
        end
      else
        @user[params[:field]] = params[params[:field]]
      end
      @user.save
    end
    render :update do |page|
      page.replace_html "field_"+params[:field], :partial =>'update_ajax.html'
    end
    # render(:layout => false)
  
  end
  
  def update
    admin_params

    eval("Settings." + params["settings"].to_unsafe_hash.to_a.first[0] + "='" + params["settings"].to_unsafe_hash.to_a.first[1] +"'"   )
  
    respond_to do |format|
      format.json  { head :ok }
      format.html { head :ok }  
    end  
  end
  
  def site_settings

    #if params.count > 2 then
    # we are doing an update on the site settings
    #  eval("Settings." + params["settings"].first[0] + "='" + params["settings"].first[1] +"'"   ) rescue ""
    #else 
    @settings = Settings.all 
    if @settings.blank? then
      Settings.test="blank";
      @settings = Settings.all 
    end
    
    @all_images = SystemImages.all rescue []
    @image_class = "none"
    # end
    @workers = Resque.workers rescue ["Redis not available[#{$!.message}]"]
    @page_list= [["N O N E (select to clear)",""]]+  Page.all.collect {|e| [e.title, e.slug || e.title]}

    #    respond_to do |format|
    #      format.html 
    #    end  
    
    
  end
  
  
  def add_image
  
    admin_params

    @image_param=params[:image]
    format = params[:format]
    puts(@image_param.inspect)
    @image= SystemImages[params[:image_name]] = @image_param
    @images = SystemImages.all
    respond_to do |format|
      flash[:notice] = 'Picture was successfully added.'
      format.js do
        responds_to_parent do
          render :update do |page|
            page.replace_html("images" , :partial => "images" , :object => @images)
            if SystemImages.count >= 100 then
              page.hide "imagebutton"
            end
            page.hide "loader_progress"
            page.show "upload-form"
            # page.call "alert", "test"
            page.call "updateBestinplaceImageTitles"
            #           page.call("jQuery('#loader_progress').toggle();")
            # page.call("jQuery('#upload-form').toggle();")
            # page.call("jQuery('.imageSingle .best_in_place').best_in_place();");
            page.visual_effect :highlight, "image_#{@image.id}"
            page[:images].show if SystemImages.count == 1
          end
        end
      end

      format.html { redirect_to :action => 'show', :id => params[:id] }
    end
  end

  def delete_image
    
    admin_params

    @all_images = SystemImages.all

    @image = Picture.find(params[:id])
    @image.destroy
   
    
    respond_to do |format|
      format.js if request.xhr?
      format.html { head :ok }
    end
  end


  def destroy_image
    admin_params

    @all_images = SystemImages.all

    @image = Picture.find(params[:id])
    @image.destroy
    respond_to do |format|
      format.json  { head :ok }
      format.html {head :ok}
    end    
  end

  def update_image_order
    admin_params

    params[:album].each_with_index do |id, position|
      #   Image.update(id, :position => position)
      Picture.reorder(id,position)
    end
    render body: nil

  end
    
  
  def reload_rails_env
   
    # Rails::ConsoleMethods.reload!
  
  end
     
  def toggle_index
    params = admin_params

    time_items = Settings.down_time.split(":") 
    up_time = Time.now.utc + time_items[0].to_i.days + time_items[1].to_i.hours + time_items[2].to_i.minutes 
    out_time =   up_time.strftime("%m/%d/%Y %I:%M %p UTC")   #=> "6/9/2016 10:25 AM"

    begin
      FileUtils.mv 'public/index.html', 'public/index.off'
    rescue
      FileUtils.mv  'public/index.off',  'public/index.html'
      File.write('public/splash/waittime.js', "// Auto written by silverweb_cms \n\r \n\r var TargetDate = \"#{out_time}\"; \n")
    end
    
    respond_to do |format|
      format.js {}
      format.json  { head :ok }
      format.html { render body: nil }
    end  
  end

  
  
  def kill_all_workers     
    admin_params

    
    @workers = Resque.workers
    @workers.each do |worker|
      Resque.remove_worker(worker.id)
    end
     
    respond_to do |format|
      format.json  { head :ok }
      render body: nil
    end  
  end
  
  
 
  def reprocess_page_images
    
    
    @pictures = Picture.all
    
    @pictures.each do |picture|
      picture.image.recreate_versions!     
    end
    
    # TinyPrint.all.each {|s| s.image.reprocess! if s.image}
    
    respond_to do |format|
      format.json  { head :ok }
      render body: nil
    end  
  end
  
  def clear_user_locks
    user =  User.find_by_id(session[:user_id])

    session[:current_action] = ""
    session[:current_controller] = ""
    session[:current_record_id] = 0
              
    user.user_live_edit.current_type = ""
    user.user_live_edit.current_action = ""
    user.user_live_edit.current_id = 0
    user.user_live_edit.save  
      
    render body: nil

  end
  
  def admin_params
    params.permit([:name, :password, :pointer_class, :id, :field_id, :field, :settings,:image, :format,:image_name,:album,:product_id])
  end
end

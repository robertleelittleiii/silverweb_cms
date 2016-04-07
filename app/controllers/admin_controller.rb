class AdminController < ApplicationController
  # just display the form and wait for user to
  # enter a name and password

  def login
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || { :action => "index" })
      else
        flash.now[:notice] = "Invalid user/password combination"
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
    @alert_message=""
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
    eval("Settings." + params["settings"].to_a.first[0] + "='" + params["settings"].to_a.first[1] +"'"   )
  
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

    #    respond_to do |format|
    #      format.html 
    #    end  
    
    
  end
  
  
  def add_image
  
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
    @all_images = SystemImages.all

    @image = Picture.find(params[:id])
    @image.destroy
   
    
    respond_to do |format|
      format.js if request.xhr?
      format.html { head :ok }
    end
  end


  def destroy_image
    @all_images = SystemImages.all

    @image = Picture.find(params[:id])
    @image.destroy
    respond_to do |format|
      format.json  { head :ok }
      format.html {head :ok}
    end    
  end

  def update_image_order
    params[:album].each_with_index do |id, position|
      #   Image.update(id, :position => position)
      Picture.reorder(id,position)
    end
    render :nothing => true

  end
    
  
  def reload_rails_env
   
    # Rails::ConsoleMethods.reload!
  
  end
     
  def toggle_index
    begin
      FileUtils.mv 'public/index.html', 'public/index.off'
    rescue
      FileUtils.mv  'public/index.off',  'public/index.html'
    end
    respond_to do |format|
      format.json  { head :ok }
      format.html {redirect_to :action => 'site_settings', :id=>params[:product_id]}
    end  
  end

  def reprocess_product_images
    @products = Product.all
    
    @products.each do |product|
      product.pictures.each do |picture|
      
        picture.image.recreate_versions!     
      end
    end
    respond_to do |format|
      format.json  { head :ok }
      format.html {redirect_to :action => 'site_settings', :id=>params[:product_id]}
    end  
  end
  
  def kill_all_workers
    @workers = Resque.workers
    @workers.each do |worker|
      Resque.remove_worker(worker.id)
    end
     
    respond_to do |format|
      format.json  { head :ok }
      format.html {redirect_to :action => 'site_settings', :id=>params[:product_id]}
    end  
  end
  
  
  def clean_product_details 
    puts("**** Begin Clean of DB: Lost Children")
    bulk_clean_product_detail_sql = ["
      Delete
      FROM product_details
      WHERE NOT EXISTS (
            SELECT 1 FROM products
            WHERE products.id = product_details.product_id
           );
      "]
    
    bulk_clean_product_detail_2_sql = ["Delete FROM product_details WHERE inventory_key LIKE '%%.0'"]
    
    
    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_clean_product_detail_2_sql)
      result = ActiveRecord::Base.connection.execute(sql)
    rescue
      puts "something went wrong with the bulk clean sql query 2 #{result.inspect}: #{sql.inspect}"
    end
    
    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_clean_product_detail_sql)
      ActiveRecord::Base.connection.execute(sql)
    rescue
      "something went wrong with the bulk insert sql query"
    end
    
    puts("**** Begin Clean of DB: BAD UPC Children")

    respond_to do |format|
      format.json  { head :ok }
      format.html {redirect_to :action => 'site_settings', :id=>params[:product_id]}
    end  
    puts("**** END Clean of DB")

  end
  
  
  def activate_all_products
    bulk_activate_products_sql = ["
         Update 
           products p
         Join 
           product_details pd on p.id = pd.product_id
         SET 
           p.product_active = 1
         where
           pd.units_in_stock > 0
      "] 
 
    bulk_activate_details_sql = ["
        Update 
           product_details pd
         SET 
           pd.sku_active = 1
         where
           pd.units_in_stock > 0;
      "] 

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_activate_products_sql)
      ActiveRecord::Base.connection.execute(sql)
    rescue
      "something went wrong with the bulk insert sql query"
    end
    
  
    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_activate_details_sql)
      ActiveRecord::Base.connection.execute(sql)
    rescue
      "something went wrong with the bulk insert sql query"
    end
    
    respond_to do |format|
      format.json  { head :ok }
      format.html {redirect_to :action => 'site_settings', :id=>params[:product_id]}
    end  
  end
  
  def clear_product_inventory_and_make_all_inactive 
    puts("**** Begin Clean of DB: clear active products")
    bulk_clear_active_product_flag_sql = ["
      Update 
         products p
      SET 
         p.product_active = 0
      where 1=1
      "]
    
    bulk_clear_active_product_detail_flag_sql = ["
      Update 
         product_details pd
      SET 
         pd.sku_active = 0,
         pd.units_in_stock = 0
      where 1=1
      "]
  
    
    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_clear_active_product_flag_sql)
      result = ActiveRecord::Base.connection.execute(sql)
    rescue
      puts "something went wrong with the bulk clear active products #{result.inspect}: #{sql.inspect}"
    end
    
    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_clear_active_product_detail_flag_sql)
      ActiveRecord::Base.connection.execute(sql)
    rescue
      "something went wrong with the bulk clear active product details"
    end
    
    puts("**** Begin Clean of DB: BAD UPC Children")

    respond_to do |format|
      format.json  { head :ok }
      format.html {redirect_to :action => 'site_settings', :id=>params[:product_id]}
    end  
    puts("**** END Clean of DB")

  end
  
  def reprocess_page_images
    
    
    @pictures = Picture.all
    
    @pictures.each do |picture|
      picture.image.recreate_versions!     
    end
    
    # TinyPrint.all.each {|s| s.image.reprocess! if s.image}
    
    respond_to do |format|
      format.json  { head :ok }
      format.html {redirect_to :action => 'site_settings', :id=>params[:product_id]}
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
      
        render :nothing=>true

  end
end

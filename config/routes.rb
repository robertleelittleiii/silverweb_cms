Rails.application.routes.draw do
  
  resources :admin do
    collection do
      get "user_administration"
      get "logout"
      get "index"
      get "site_settings"
      get "toggle_index"
      get "reprocess_page_images"
      get "update_ajax"
      get "update"
    end
  end
  resources :site do
    collection do
      get "show_page"
      get "show_page_popup"
      post "login"
      post "login_ajax"
      post "reset_ajax"
      post "register_ajax"
      get "logout_ajax"
      get "render_partial"
      get "load_asset"
   end 
  end
  
  resource :pictures do
    collection do
      get "edit"
      get "insert"
      get "render_picture"
      get "insert_image"
    end
  end
  
  resource :image_library do
    collection do
    get "image_list"
    post "image_list"
    end
  end
  
    resources :page_templates do
    collection do
      get "create_empty_record"
      get "template_list"
    end
  end
  
  
  resources :registration do
    collection do
      get "login"
      get "forgot"
      post "forgot"
      get "reset"
      post "reset"
      get "password_is_reset"
      get "registration"
      get "lostwithemail"
      get "testinventory"
    end
  end

  resources :sliders do
    collection do
      get "create_empty_record"
      post "sort"
    end
  end

  get "mailer/simple_form"

  resources :pictures do
    collection do
      get "download_file"
      delete "delete"
      get "render_pictures"
    end
  end

  resources :menus do
    collection do
      post "ajax_load_partial"
      post "update_order"
      get "create_empty_record"
      get "ajax_load_partial"
      get "update_menu_list"
      get "render_menu_list"
      post "add_image"
      get "render_menu"
    end
  end

  resources :user_attributes

  resources :roles do
    collection do
      get "role_table"
      get "change_password" 
      get "update_rights"
      get "create_empty_record"
      get "delete_ajax"
    end
  end

  resources :rights

resources :users do
    collection do
      get "user_table"
      get "change_password" 
      get "update_roles"
      get "create_empty_record"
      get "delete_ajax"
      get "update_password"
    end
  end
  
  #get "site/index.html"

  resources :pages do
    collection do
      get "create_empty_record"
      get "get_sliders_list"
      get "page_table"
      get "delete_ajax"
      get "custom"
      get "link_list"
      post "update_checkbox_tag"
    end
  end
  
  
  resources :attachments do
    new do
      get "create"
    end
    collection do
      get "manage"
    end
    collection do
      get "delete"
    end
  end
  
  match  '/forgot', :controller => 'registration', :action => 'forgot', via: [:post]
  match  '/lost',                            :controller => 'registration',     :action => 'lost',  via: [:post]
  match '/reset/:reset_code',                  :controller => 'registration',     :action => 'reset', via: [:post]
  match '/activate/:activation_code',          :controller => 'registration',     :action => 'activate', via: [:post]
  
  
 #  match ':page_name(.:format)', :controller => 'site', :action => 'show_page',  via: [:get]
 
  # match ':controller(/:action(/:id(.:format)))'

  # match '*a.htm' => redirect("/site", :status => 302)

  match ':page_name(.:format)', :controller => 'site', :action => 'show_page',  via: [:get]
   
  root :to => "site#index"

end

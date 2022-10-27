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
      post "clear_user_locks"
      post "refresh_user_live_edit"
    end
  end
  resources :site do
    collection do
      get "show_page"
      get "show_page_popup"
      get "login"
      post "login_ajax"
      post "reset_ajax"
      post "register_ajax"
      get "logout_ajax"
      get "render_partial"
      get "load_asset"
      post "session_active"
      get "custom"
      get "link_list"
      get "template_list"
      get "reset"
      post "set_time_zone"
      post "check_session"
      get "get_csrf_meta_tags"
      post "update_menu_order"
      post "update_menu_shortcuts"
      get "code_mirror"
    end 
  end
  
  resource :pictures do
    collection do
      get "edit"
      get "insert"
      get "render_picture"
      get "insert_image"
      get "render_pictures"
      get "search"
    end
  end
  
  resource :image_library do
    collection do
      get "image_list"
      post "image_list"
      
      get 'next_images'
      post 'next_images'
    end
  end
  
  resources :page_templates do
    collection do
      get "create_empty_record"
      get "template_list"
      get "index"
      post "page_template_table"
      get "insert"
    end
  end
  
  
  resources :registration do
    collection do
      get "login"
      get "forgot"
      post "forgot"
      get "reset"
      post "reset"
      get "reset_ajax"
      post "reset_ajax"
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
      get "delete_ajax"
    end
  end

  resources :user_attributes

  resources :roles do
    collection do
      post "role_table"
      get "change_password" 
      get "update_rights"
      get "create_empty_record"
      get "delete_ajax"
    end
  end

  resources :rights do
    collection do
      post "right_table"
      get "delete_ajax"
      get "create_empty_record"
      get "update_actions"
    end
  end

  resources :users do
    collection do
      post "user_table"
      get "change_password" 
      get "update_roles"
      get "create_empty_record"
      get "delete_ajax"
      patch "update_password"
      post "set_time_zone"
    end
  end
  
  #get "site/index.html"

  resources :pages do
    collection do
      get "create_empty_record"
      get "get_sliders_list"
      post "page_table"
      get "delete_ajax"
      get "link_list"
      post "update_checkbox_tag"
      get "custom"
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
  
  post "mailer/simple_form"

  match '/spellchecker', :controller=>'spelling', :action => 'index', via: [:post]
  
  match  '/forgot', :controller => 'registration', :action => 'forgot', via: [:get]
  match  '/lost',                            :controller => 'registration',     :action => 'lost',  via: [:get]
  match '/activate/:activation_code',          :controller => 'registration',     :action => 'activate', via: [:get]
  
  # match '/:slug' => "site#show_page", :slug => :slug, via: [:get, :post]

  
  #  match ':page_name(.:format)', :controller => 'site', :action => 'show_page',  via: [:get]
 
  # match ':controller(/:action(/:id(.:format)))'

  # match '*a.htm' => redirect("/site", :status => 302)

  #
  #  Using route list:
  #
  #       format: match ':page_name(.:format)', :controller => 'site', :action => 'show_page',  via: [:get]
  #
  #
  
  SilverwebCms::Config.DIRECT_ROUTE_LIST.each do |route|
    match route[:match], :controller=>route[:controller], :action=>route[:action],  via: route[:via] 
  end
  
  root :to => "site#index"

end

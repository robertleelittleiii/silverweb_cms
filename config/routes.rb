Rails.application.routes.draw do
  
  resource :image_library do
    collection do
      get "image_list"
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
      get "create_empty_record"
      get "ajax_load_partial"
    end
  end

  resources :user_attributes

  resources :roles do
    collection do
      get "role_table"
      get "change_password" 
      get "update_rights"
      get "create_empty_record"
    end
  end

  resources :rights

resources :users do
    collection do
      get "user_table"
      get "change_password" 
      get "update_roles"
      get "create_empty_record"
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

end

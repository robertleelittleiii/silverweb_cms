module SilverwebCms
  #include 'tinymce-rails'
  require 'tinymce-rails'
  #require 'jquery-turbolinks'
  require 'jquery-fileupload-rails'
  require 'kaminari'
  require 'jquery-rails'
  require 'jquery-ui-rails'
  require 'non-stupid-digest-assets'
  # require 'activerecord-session_store'
  require 'active_record/session_store'

  #  require 'gavtastic'
  #  
  # require 'RFC822'
 
  class Engine < ::Rails::Engine
    #  require 'jquery-turbolinks'
    require 'acts-as-taggable-on'
    require 'carrierwave'
    require 'rails-settings-cached'
    require 'vestal_versions'
    require 'rack-mini-profiler'
    require 'non-stupid-digest-assets'
    require 'sitemap_generator'
    require 'rack-mini-profiler'
    require 'active_record/session_store'

    #     require 'activerecord-session_store'
    
    # isolate_namespace SilverwebCms
    ActiveSupport.on_load(:action_controller) do
      include SilverwebCms::Controller # ActiveSupport::Concern
    end
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end

module SilverwebCms
 #include 'tinymce-rails'
 require 'tinymce-rails'
 require 'jquery-fileupload-rails'

  class Engine < ::Rails::Engine
    require 'acts-as-taggable-on'
    require 'carrierwave'
    # isolate_namespace SilverwebCms
    
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end

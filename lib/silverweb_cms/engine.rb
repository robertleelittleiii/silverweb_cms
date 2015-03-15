module SilverwebCms
 #include 'tinymce-rails'
 require 'tinymce-rails'
 require 'jquery-turbolinks'
 require 'jquery-fileupload-rails'
 require 'kaminari'

  class Engine < ::Rails::Engine
    require 'jquery-turbolinks'
    require 'acts-as-taggable-on'
    require 'carrierwave'
    require 'rails-settings-cached'
    require 'vestal_versions'

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

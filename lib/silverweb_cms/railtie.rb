module SilverwebCms
  class Railtie < Rails::Railtie
    initializer "silverweb_cms.action_controller" do
      ActiveSupport.on_load(:action_controller) do
        puts "Extending #{self} with silverweb_cms"
        # ActionController::Base gets a method that allows controllers to include the new behavior
        include SilverwebCms::Controller # ActiveSupport::Concern
      end
    end
  end
end
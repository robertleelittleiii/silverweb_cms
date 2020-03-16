$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "silverweb_cms/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "silverweb_cms"
  s.version     = SilverwebCms::VERSION
  s.authors     = ["Robert Lee Little III"]
  s.email       = ["rob@silverwebsystems.com"]
  s.homepage    = "http://www.silverwebsystems.com/"
  s.summary     = "This is a baseline CMS system built by silverwebs sytems"
  s.description = "This CMS alows for Menus and Pages object.  Each page can have sliders.  Also has a built in secutiy model (Model/controller/Action Roles/Rules)"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_runtime_dependency "tinymce-rails"#, "4.7.2" # ">=4.3.12" locked in due to bug with gem.
  
  # s.add_runtime_dependency "compass" , "~> 1.0.0"
  # s.add_runtime_dependency "sass-rails" , "5.0.0"
  # s.add_runtime_dependency "sprockets" , "3.5.2"
  # s.add_runtime_dependency "compass-rails" , "~> 2.0.4"
  
  s.add_runtime_dependency "rails", '~> 5.1'
  s.add_runtime_dependency 'jquery-rails'
  s.add_runtime_dependency 'rmagick'

  s.add_runtime_dependency 'jquery-ui-rails'
  s.add_runtime_dependency 'jquery-fileupload-rails'
  #  s.add_runtime_dependency 'turbolinks', '~> 2.5', '>= 2.5.3'
  # s.add_runtime_dependency 'jquery-turbolinks','~> 2.1', '>= 2.1.0'
  s.add_runtime_dependency 'railties'

  # s.add_runtime_dependency 'vestal_versions'
  
  s.add_runtime_dependency "acts-as-taggable-on"
  # s.add_dependency "rails-settings-cached", "0.4.1"
  s.add_runtime_dependency 'rails-settings-cached', '0.4.1' 
  # s.add_runtime_dependency 'robertleelittleiii/vestal_versions'
  s.add_runtime_dependency 'carrierwave'
  s.add_runtime_dependency 'kaminari'
  s.add_runtime_dependency 'rack-mini-profiler'
  s.add_runtime_dependency 'non-stupid-digest-assets'
  s.add_runtime_dependency 'gravtastic'
  s.add_development_dependency "mysql"
  s.add_development_dependency 'gem_reloader'
  s.add_runtime_dependency 'sitemap_generator', '5.2.0'
  s.add_runtime_dependency 'american_date'
  s.add_runtime_dependency 'activerecord-session_store'
  s.add_runtime_dependency 'browser'

  
end

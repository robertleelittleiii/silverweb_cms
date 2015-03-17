$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "silverweb_cms/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "silverweb_cms"
  s.version     = SilverwebCms::VERSION
  s.authors     = ["Robert Lee Little III"]
  s.email       = ["robertleelittle@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SilverwebCms."
  s.description = "TODO: Description of SilverwebCms."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'jquery-ui-rails'
  s.add_dependency "rails", "~> 4.2.0"
  s.add_dependency "tinymce-rails"
  s.add_dependency 'vestal_versions'
  s.add_dependency "acts-as-taggable-on"
  s.add_dependency "rails-settings-cached", "0.4.1"
  s.add_dependency 'carrierwave'
  s.add_dependency 'rmagick'
  s.add_dependency 'kaminari'
  s.add_dependency 'jquery-fileupload-rails'
  s.add_dependency 'rails-settings-cached'
  s.add_dependency 'jquery-turbolinks'
  s.add_dependency 'rack-mini-profiler'
  
  s.add_development_dependency "mysql"
end

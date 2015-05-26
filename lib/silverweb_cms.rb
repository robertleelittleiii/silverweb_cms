module SilverwebCms
  puts "Loading SilverwebCms..."
  require "silverweb_cms/controller"  #  To allow added controller actions.
  require "silverweb_cms/base"
  require "silverweb_cms/engine"

  module Helpers
    autoload :Helpers, 'silverweb_cms/helpers'
  end
end

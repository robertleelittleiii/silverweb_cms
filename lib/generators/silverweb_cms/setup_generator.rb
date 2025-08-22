# lib/generators/silverweb_cms/setup_generator.rb

require 'rails/generators'

module SilverwebCms
  class SetupGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc "Sets up the silverweb_cms gem with initial configuration and migrations"

    def copy_initializer
      template 'silverweb_cms.rb', 'config/initializers/silverweb_cms.rb'
    end

    def run_migrations
      rake 'db:migrate' if yes?('Would you like to run migrations now? (y/n)')
    end

    def configure_authpoint
      say "Configuring AuthPoint settings. Please provide the following:"
      authpoint_base_url = ask("AuthPoint Base URL [https://api.usa.cloud.watchguard.com]: ") do |q|
        q.default = 'https://api.usa.cloud.watchguard.com'
      end
      authpoint_auth_url = ask("AuthPoint Auth URL [https://api.usa.cloud.watchguard.com]: ") do |q|
        q.default = 'https://api.usa.cloud.watchguard.com'
      end
      authpoint_access_id = ask("AuthPoint Access ID: ") do |q|
        q.default = nil
      end
      authpoint_password = ask("AuthPoint Password: ") { |q| q.echo = false }
      authpoint_account_id = ask("AuthPoint Account ID: ") do |q|
        q.default = nil
      end
      authpoint_resource_id = ask("AuthPoint Resource ID: ") do |q|
        q.default = nil
      end
      authpoint_api_key = ask("AuthPoint API Key: ") do |q|
        q.default = nil
      end
      authpoint_client_id = ask("AuthPoint Client ID (optional): ")

      # Validate required fields
      required_fields = {
        'AuthPoint Access ID' => authpoint_access_id,
        'AuthPoint Password' => authpoint_password,
        'AuthPoint Account ID' => authpoint_account_id,
        'AuthPoint Resource ID' => authpoint_resource_id,
        'AuthPoint API Key' => authpoint_api_key
      }
      missing_fields = required_fields.select { |k, v| v.nil? || v.empty? }.keys
      unless missing_fields.empty?
        raise "Missing required fields: #{missing_fields.join(', ')}"
      end

      # Write to .env file (for development)
      File.open('.env', 'a') do |f|
        f.puts "\n# Silverweb CMS AuthPoint Configuration"
        f.puts "AUTHPOINT_BASE_URL=#{authpoint_base_url}"
        f.puts "AUTHPOINT_AUTH_URL=#{authpoint_auth_url}"
        f.puts "AUTHPOINT_ACCESS_ID=#{authpoint_access_id}"
        f.puts "AUTHPOINT_PASSWORD=#{authpoint_password}"
        f.puts "AUTHPOINT_ACCOUNT_ID=#{authpoint_account_id}"
        f.puts "AUTHPOINT_RESOURCE_ID=#{authpoint_resource_id}"
        f.puts "AUTHPOINT_API_KEY=#{authpoint_api_key}"
        f.puts "AUTHPOINT_CLIENT_ID=#{authpoint_client_id}" unless authpoint_client_id.empty?
        f.puts "SILVERWEB_CMS_SETUP_COMPLETE=true" # Mark setup as complete
      end

      say 'AuthPoint configuration added to .env. Please ensure dotenv-rails is in your Gemfile.'
    end

    def show_next_steps
      say <<-MSG
        Setup complete! Next steps:
        1. Add 'gem "dotenv-rails"' to your Gemfile if not already present.
        2. Run 'bundle install'.
        3. Restart your Rails server to load the new configuration.
        4. Verify AuthPoint settings in config/initializers/silverweb_cms.rb.
      MSG
    end
  end
end
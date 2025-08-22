# config/initializers/silverweb_cms.rb

# Load environment variables from .env file if using dotenv-rails
if Rails.env.development? || Rails.env.test?
  begin
    require 'dotenv/load'
  rescue LoadError
    Rails.logger.warn('dotenv-rails not found. Ensure it\'s in your Gemfile and run bundle install.')
  end
end

module SilverwebCms
  class Configuration
    class << self
      def authpoint_base_url
        ENV['AUTHPOINT_BASE_URL'] || 'https://api.usa.cloud.watchguard.com'
      end

      def authpoint_auth_url
        ENV['AUTHPOINT_AUTH_URL'] || 'https://api.usa.cloud.watchguard.com'
      end

      def authpoint_access_id
        value = ENV['AUTHPOINT_ACCESS_ID']
        check_setup
        raise 'AUTHPOINT_ACCESS_ID is required' if value.nil? || value.empty?
        value
      end

      def authpoint_password
        value = ENV['AUTHPOINT_PASSWORD']
        check_setup
        raise 'AUTHPOINT_PASSWORD is required' if value.nil? || value.empty?
        value
      end

      def authpoint_account_id
        value = ENV['AUTHPOINT_ACCOUNT_ID']
        check_setup
        raise 'AUTHPOINT_ACCOUNT_ID is required' if value.nil? || value.empty?
        value
      end

      def authpoint_resource_id
        value = ENV['AUTHPOINT_RESOURCE_ID']
        check_setup
        raise 'AUTHPOINT_RESOURCE_ID is required' if value.nil? || value.empty?
        value
      end

      def authpoint_api_key
        value = ENV['AUTHPOINT_API_KEY']
        check_setup
        raise 'AUTHPOINT_API_KEY is required' if value.nil? || value.empty?
        value
      end

      def authpoint_client_id
        ENV['AUTHPOINT_CLIENT_ID']
      end

      def authpoint_audience
        ENV['AUTHPOINT_AUDIENCE']
      end

      private

      def check_setup
        return if Rails.env.test? || ENV['SILVERWEB_CMS_SETUP_COMPLETE'] == 'true'
        Rails.logger.warn('Silverweb CMS setup not completed. ' +
                          'Please run `rails generate silverweb_cms:setup` to configure AuthPoint settings.')
        raise 'Silverweb CMS setup required' unless Rails.env.development?
      end
    end
  end
end

AUTHPOINT_CONFIG = SilverwebCms::Configuration

# Optional: Log loaded configuration for debugging (in development only)
if Rails.env.development?
  begin
    Rails.logger.info("AuthPoint Configuration: Base URL: #{AUTHPOINT_CONFIG.authpoint_base_url}, " +
                      "Auth URL: #{AUTHPOINT_CONFIG.authpoint_auth_url}, " +
                      "Account ID: #{AUTHPOINT_CONFIG.authpoint_account_id}, " +
                      "Resource ID: #{AUTHPOINT_CONFIG.authpoint_resource_id}")
  rescue StandardError => e
    Rails.logger.warn("AuthPoint configuration check failed: #{e.message}")
  end
end

# Ensure required environment variables are set in production
if Rails.env.production?
  required_vars = %w[AUTHPOINT_ACCESS_ID AUTHPOINT_PASSWORD AUTHPOINT_ACCOUNT_ID
                     AUTHPOINT_RESOURCE_ID AUTHPOINT_API_KEY]
  missing_vars = required_vars.select { |var| ENV[var].nil? || ENV[var].empty? }
  unless missing_vars.empty?
    raise "Missing required environment variables in production: #{missing_vars.join(', ')}"
  end
end
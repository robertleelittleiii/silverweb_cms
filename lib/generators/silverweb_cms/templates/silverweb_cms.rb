# templates/silverweb_cms.rb

# Load environment variables from .env file if using dotenv-rails
if Rails.env.development? || Rails.env.test?
  require 'dotenv/load'
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
        ENV['AUTHPOINT_ACCESS_ID'] || raise('AUTHPOINT_ACCESS_ID is required')
      end

      def authpoint_password
        ENV['AUTHPOINT_PASSWORD'] || raise('AUTHPOINT_PASSWORD is required')
      end

      def authpoint_account_id
        ENV['AUTHPOINT_ACCOUNT_ID'] || raise('AUTHPOINT_ACCOUNT_ID is required')
      end

      def authpoint_resource_id
        ENV['AUTHPOINT_RESOURCE_ID'] || raise('AUTHPOINT_RESOURCE_ID is required')
      end

      def authpoint_api_key
        ENV['AUTHPOINT_API_KEY'] || raise('AUTHPOINT_API_KEY is required')
      end

      def authpoint_client_id
        ENV['AUTHPOINT_CLIENT_ID']
      end

      def authpoint_audience
        val = ENV['AUTHPOINT_AUDIENCE']
        val && !val.empty? ? val : nil
      end
    end
  end
end

AUTHPOINT_CONFIG = SilverwebCms::Configuration

if Rails.env.development?
  Rails.logger.info("AuthPoint Configuration: Base URL: #{AUTHPOINT_CONFIG.authpoint_base_url}, " +
                    "Auth URL: #{AUTHPOINT_CONFIG.authpoint_auth_url}, " +
                    "Account ID: #{AUTHPOINT_CONFIG.authpoint_account_id}, " +
                    "Resource ID: #{AUTHPOINT_CONFIG.authpoint_resource_id}")
end

if Rails.env.production?
  %w[AUTHPOINT_ACCESS_ID AUTHPOINT_PASSWORD AUTHPOINT_ACCOUNT_ID
     AUTHPOINT_RESOURCE_ID AUTHPOINT_API_KEY].each do |key|
    raise "#{key} is not set in production environment" unless ENV[key]
  end
end
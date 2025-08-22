# frozen_string_literal: true

# app/services/auth_point_service.rb
#
# Standalone AuthPoint service using AUTHPOINT_CONFIG
# Implements the full AuthPoint authentication flow without external dependencies
#
class AuthPointService
  include HTTParty

  attr_reader :last_qr_code

  def initialize(user, password = nil)
    @user = user
    @password = password
    @config = AUTHPOINT_CONFIG
    self.class.base_uri @config.authpoint_base_url
  end

  # Initiates AuthPoint push authentication for the user
  # Returns true when initiation succeeded (push sent), false otherwise
  def authenticate
    return false unless @user&.multi_factor_type.to_s.casecmp("Authpoint").zero?

    if @password.blank?
      Rails.logger.error("[AuthPoint] Password is required for authentication")
      return false
    end

    begin
      # First check authentication policy to ensure user can authenticate
      policy_response = check_authentication_policy(@user.name)

      unless policy_response['hasPolicy'] && policy_response['isAllowedToAuthenticate']
        Rails.logger.error("[AuthPoint] User #{@user.name} is not allowed to authenticate")
        return false
      end

      # Determine available auth methods
      auth_methods = policy_response['authenticationMethods'] || []

      if auth_methods.include?('Push')
        # Initiate push authentication with password
        auth_response = authenticate_user(@user.name, 'push', nil, { password: @password })

        transaction_id = auth_response['transactionId']
        if transaction_id.present?
          @user.update_column(:authpoint_session_id, transaction_id)
          Rails.logger.info("[AuthPoint] Push authentication initiated for #{@user.name}, transaction: #{transaction_id}")
          return true
        else
          Rails.logger.error("[AuthPoint] No transaction ID returned for push for #{@user.name}")
          return false
        end
      elsif auth_methods.include?('QRCode')
        # Initiate QR code authentication with password (if required by policy)
        auth_response = authenticate_user(@user.name, 'qrcode', nil, { password: @password })

        transaction_id = auth_response['transactionId']
        qr_code = auth_response['qrCode'] || auth_response['qrcode'] || auth_response['command']
        if transaction_id.present?
          @user.update_column(:authpoint_session_id, transaction_id)
          @last_qr_code = qr_code
          # Persist the last QR code on the user for later retrieval/display
          begin
            @user.update_column(:authpoint_last_qr_code, @last_qr_code)
          rescue => e
            Rails.logger.warn("[AuthPoint] Unable to persist authpoint_last_qr_code for #{@user.name}: #{e.message}")
          end
          Rails.logger.info("[AuthPoint] QR code authentication initiated for #{@user.name}, transaction: #{transaction_id}")
          return true
        else
          Rails.logger.error("[AuthPoint] No transaction ID returned for qrcode for #{@user.name}")
          return false
        end
      else
        Rails.logger.error("[AuthPoint] No supported authentication methods (Push/QRCode) available for #{@user.name}")
        return false
      end

    rescue => e
      Rails.logger.error("[AuthPoint] authenticate error for #{@user.name}: #{e.class}: #{e.message}")
      false
    end
  end

  # Poll current authentication status for the stored transaction id
  # Returns a hash with success: boolean, status: string, message: string
  def verify_authentication
    transaction_id = @user.try(:authpoint_session_id)

    if transaction_id.to_s.strip.empty?
      return {
        success: false,
        status: "missing_session",
        message: "No AuthPoint transaction id present"
      }
    end

    begin
      status_response = poll_push_status(transaction_id)

      # Extract status from the response
      status = (status_response['status'] ||
        status_response['pushResult'] ||
        status_response['authenticationResult'] || '').to_s.upcase

      case status
      when 'ACCEPTED', 'APPROVED', 'SUCCESS', 'AUTHENTICATED', 'AUTHORIZED'
        # Clear the transaction ID and stored QR on successful authentication
        @user.update_columns(authpoint_session_id: nil, authpoint_last_qr_code: nil)
        {
          success: true,
          status: status,
          message: "Authentication approved"
        }
      when 'PENDING', 'WAITING', 'INITIATED', 'STATUS'
        {
          success: false,
          status: status,
          message: "Authentication pending - please check your mobile device"
        }
      when 'DENIED', 'REJECTED', 'FAILED', 'TIMEOUT', 'EXPIRED', 'CANCELLED'
        # Clear the transaction ID and stored QR on failed/denied authentication
        @user.update_columns(authpoint_session_id: nil, authpoint_last_qr_code: nil)
        {
          success: false,
          status: status,
          message: "Authentication #{status.downcase}"
        }
      else
        Rails.logger.warn("[AuthPoint] Unknown status '#{status}' for transaction #{transaction_id}")
        {
          success: false,
          status: status,
          message: "Unknown authentication status: #{status}"
        }
      end

    rescue => e
      Rails.logger.error("[AuthPoint] verify_authentication error for transaction #{transaction_id}: #{e.class}: #{e.message}")

      # If we get a 403 error, it might mean the transaction expired or was completed
      if e.message.include?('403') || e.message.include?('Unauthorized')
        @user.update_columns(authpoint_session_id: nil, authpoint_last_qr_code: nil)
        {
          success: false,
          status: "expired",
          message: "Authentication session expired"
        }
      else
        {
          success: false,
          status: "error",
          message: "AuthPoint status check failed: #{e.message}"
        }
      end
    end
  end

  # Check if user has valid authentication policy
  def check_policy(origin_ip = nil)
    begin
      policy_response = check_authentication_policy(@user.name, origin_ip)
      {
        success: true,
        has_policy: policy_response['hasPolicy'],
        allowed: policy_response['isAllowedToAuthenticate'],
        methods: policy_response['authenticationMethods'] || []
      }
    rescue => e
      Rails.logger.error("[AuthPoint] policy check error for #{@user.name}: #{e.class}: #{e.message}")
      {
        success: false,
        error: e.message
      }
    end
  end

  private

  # Get OAuth access token for API calls
  def get_access_token
    return @access_token if defined?(@access_token) && @access_token.present?

    access_id = @config.authpoint_access_id
    password = @config.authpoint_password
    auth_url = @config.authpoint_auth_url

    # Validate URL format
    unless URI.parse(auth_url).host &&
           auth_url.match?(/https:\/\/api\.[a-z]+\.cloud\.watchguard\.com/)
      error_message = "Invalid AUTHPOINT_AUTH_URL format: #{auth_url}. " +
                      'Expected https://api.<region>.cloud.watchguard.com'
      Rails.logger.error(error_message)
      raise error_message
    end

    body_params = {
      grant_type: 'client_credentials',
      scope: 'api-access'
    }
    body_params[:audience] = @config.authpoint_audience if @config.authpoint_audience

    response = self.class.post(
      "#{auth_url}/oauth/token",
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Accept' => 'application/json'
      },
      body: body_params,
      basic_auth: {
        username: access_id,
        password: password
      }
    )

    if response.success?
      token = response.parsed_response['access_token']
      if token.nil? || token.empty?
        error_message = "Access token not found in response: #{response.body}"
        Rails.logger.error(error_message)
        raise error_message
      end
      Rails.logger.info('[AuthPoint] Successfully retrieved access token')
      @access_token = token
    else
      error_message = "Failed to get AuthPoint access token: #{response.code} - #{response.body}"
      Rails.logger.error(error_message)
      raise error_message
    end
  rescue StandardError => e
    error_message = "AuthPoint token request error: #{e.message}"
    Rails.logger.error(error_message)
    raise e
  end

  # Check authentication policy for a user
  def check_authentication_policy(login, origin_ip = nil)
    if login.nil? || login.empty?
      error_message = 'Login parameter is required'
      Rails.logger.error(error_message)
      raise error_message
    end

    access_token = get_access_token
    body = { login: login }
    body[:originIpAddress] = origin_ip if origin_ip

    account_id = @config.authpoint_account_id
    resource_id = @config.authpoint_resource_id
    api_key = @config.authpoint_api_key

    request_url = "/rest/authpoint/authentication/v1/accounts/#{account_id}/resources/#{resource_id}/authenticationpolicy"
    Rails.logger.info("[AuthPoint] Checking policy with URL: #{self.class.base_uri}#{request_url}")

    response = self.class.post(
      request_url,
      headers: {
        'Authorization' => "Bearer #{access_token}",
        'WatchGuard-API-Key' => api_key,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      },
      body: body.to_json
    )

    if response.success?
      policy_response = response.parsed_response
      unless policy_response['hasPolicy'] && policy_response['isAllowedToAuthenticate']
        error_message = "User #{login} is not allowed to authenticate: #{response.body}"
        Rails.logger.error(error_message)
        raise error_message
      end

      policy = policy_response['policyResponse'] || {}
      auth_methods = []
      auth_methods << 'Push' if policy['push']
      auth_methods << 'OTP' if policy['otp']
      auth_methods << 'QRCode' if policy['qrCode']

      if auth_methods.empty?
        error_message = "No valid authentication methods found in policyResponse: #{response.body}"
        Rails.logger.error(error_message)
        raise error_message
      end

      Rails.logger.info("[AuthPoint] Successfully checked authentication policy for #{login}: #{auth_methods}")
      policy_response['authenticationMethods'] = auth_methods
      policy_response
    else
      error_message = "Failed to check authentication policy: #{response.code} - #{response.body}"
      Rails.logger.error(error_message)
      raise error_message
    end
  rescue StandardError => e
    error_message = "AuthPoint policy check error: #{e.message}"
    Rails.logger.error(error_message)
    raise e
  end

  # Authenticate user with specified method
  def authenticate_user(login, auth_type, origin_ip = nil, auth_data = {})
    if login.nil? || login.empty?
      error_message = 'Login parameter is required'
      Rails.logger.error(error_message)
      raise error_message
    end

    unless ['push', 'otp', 'qrcode', 'qrcode_response'].include?(auth_type.downcase)
      error_message = "Invalid authentication type: #{auth_type}. Supported: push, otp, qrcode, qrcode_response"
      Rails.logger.error(error_message)
      raise error_message
    end

    access_token = get_access_token

    case auth_type.downcase
    when 'push', 'qrcode'
      body = { login: login }
      body[:originIpAddress] = origin_ip if origin_ip
      body[:type] = auth_type.upcase
      body[:password] = auth_data[:password] if auth_data[:password]
      endpoint = 'transactions'
    when 'otp'
      body = {
        login: login,
        password: auth_data[:password],
        otp: auth_data[:otp]
      }
      body[:originIpAddress] = origin_ip if origin_ip
      endpoint = 'otp'
    when 'qrcode_response'
      body = {
        login: login,
        qrCodeResponse: auth_data[:qrCodeResponse],
        transactionId: auth_data[:transactionId]
      }
      body[:originIpAddress] = origin_ip if origin_ip
      endpoint = 'qrcode'
    end

    # Validate required fields
    if ['push', 'qrcode'].include?(auth_type.downcase) && !body.key?(:type)
      error_message = "Missing type for #{auth_type}: #{redact_sensitive(body).inspect}"
      Rails.logger.error(error_message)
      raise error_message
    end
    if auth_type.downcase == 'otp' && (!body.key?(:password) || !body.key?(:otp))
      error_message = "Missing password or otp for OTP authentication: #{redact_sensitive(body).inspect}"
      Rails.logger.error(error_message)
      raise error_message
    end
    if auth_type.downcase == 'qrcode_response' && (!body.key?(:qrCodeResponse) || !body.key?(:transactionId))
      error_message = "Missing qrCodeResponse or transactionId for QRCode authentication: #{redact_sensitive(body).inspect}"
      Rails.logger.error(error_message)
      raise error_message
    end
    if ['push', 'qrcode'].include?(auth_type.downcase) && !body.key?(:password) && auth_data[:password].nil?
      error_message = "Missing password for #{auth_type} authentication: #{redact_sensitive(body).inspect}"
      Rails.logger.warn(error_message)
      # Not raising here to match helper's behavior (warn only)
    end

    account_id = @config.authpoint_account_id
    resource_id = @config.authpoint_resource_id
    api_key = @config.authpoint_api_key

    request_url = "/rest/authpoint/authentication/v1/accounts/#{account_id}/resources/#{resource_id}/#{endpoint}"
    Rails.logger.info("[AuthPoint] Authenticating with URL: #{self.class.base_uri}#{request_url}")
    # Mask sensitive fields (e.g., password) before logging
    redacted_body = redact_sensitive(body)
    Rails.logger.debug("[AuthPoint] Request body: #{redacted_body.to_json}")

    response = self.class.post(
      request_url,
      headers: {
        'Authorization' => "Bearer #{access_token}",
        'WatchGuard-API-Key' => api_key,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      },
      body: body.to_json
    )

    if response.success?
      auth_response = response.parsed_response
      if auth_response['status'].nil? && ['push', 'qrcode'].include?(auth_type.downcase)
        if auth_response['transactionId'].nil?
          error_message = "No transactionId found in response for #{auth_type}: #{response.body}"
          Rails.logger.error(error_message)
          raise error_message
        end
        Rails.logger.info("[AuthPoint] Authentication response for #{login} (#{auth_type}): #{auth_response.inspect}")
        auth_response
      elsif ['otp', 'qrcode_response'].include?(auth_type.downcase)
        if auth_response['status'].nil? && auth_response['authenticationResult'].nil?
          error_message = "No status or authenticationResult found in response for #{auth_type}: #{response.body}"
          Rails.logger.error(error_message)
          raise error_message
        else
          Rails.logger.info("[AuthPoint] Authentication response for #{login} (#{auth_type}): #{auth_response.inspect}")
          auth_response
        end
      else
        Rails.logger.info("[AuthPoint] Authentication response for #{login} (#{auth_type}): #{auth_response.inspect}")
        auth_response
      end
    else
      error_message = "Failed to authenticate: #{response.code} - #{response.body}"
      Rails.logger.error(error_message)
      raise error_message
    end
  rescue StandardError => e
    error_message = "AuthPoint authentication error: #{e.message}"
    Rails.logger.error(error_message)
    raise e
  end

  # Utility: redact sensitive fields from hashes before logging
  def redact_sensitive(obj)
    case obj
    when Hash
      obj.each_with_object({}) do |(k, v), h|
        if k.to_s.downcase == 'password'
          masked = '*' * 8
          h[k] = masked
        else
          h[k] = redact_sensitive(v)
        end
      end
    when Array
      obj.map { |e| redact_sensitive(e) }
    else
      obj
    end
  end

  # Poll push authentication status
  def poll_push_status(transaction_id)
    if transaction_id.nil? || transaction_id.empty?
      error_message = 'Transaction ID is required'
      Rails.logger.error(error_message)
      raise error_message
    end

    access_token = get_access_token
    account_id = @config.authpoint_account_id
    resource_id = @config.authpoint_resource_id
    api_key = @config.authpoint_api_key

    request_url = "/rest/authpoint/authentication/v1/accounts/#{account_id}/resources/#{resource_id}/transactions/#{transaction_id}"
    Rails.logger.info("[AuthPoint] Polling push status with URL: #{self.class.base_uri}#{request_url}")

    response = self.class.get(
      request_url,
      headers: {
        'Authorization' => "Bearer #{access_token}",
        'WatchGuard-API-Key' => api_key,
        'Accept' => 'application/json'
      }
    )

    if response.success? || response.code == 202
      status_response = response.parsed_response

      status = status_response['status'] || status_response['pushResult'] ||
               status_response['authenticationResult']

      if status.nil?
        error_message = "No status found in poll response: #{response.body}"
        Rails.logger.error(error_message)
        raise error_message
      end

      Rails.logger.info("[AuthPoint] Push status for transaction_id #{transaction_id}: #{status_response.inspect}")
      status_response
    elsif response.code == 403
      error_message = "Unauthorized access to transaction #{transaction_id}: " +
                      "#{response.code} - #{response.body}. " +
                      "Check user approval or API permissions."
      Rails.logger.error(error_message)
      raise error_message
    else
      error_message = "Failed to poll push status: #{response.code} - #{response.body}"
      Rails.logger.error(error_message)
      raise error_message
    end
  rescue StandardError => e
    error_message = "AuthPoint push poll error: #{e.message}"
    Rails.logger.error(error_message)
    raise e
  end

  # Cancel current authentication transaction
  def cancel_authentication
    transaction_id = @user.try(:authpoint_session_id)
    return true if transaction_id.blank?

    begin
      # Clear the transaction ID
      @user.update_column(:authpoint_session_id, nil)
      Rails.logger.info("[AuthPoint] Authentication cancelled for #{@user.name}, transaction: #{transaction_id}")
      true
    rescue => e
      Rails.logger.error("[AuthPoint] cancel_authentication error: #{e.class}: #{e.message}")
      false
    end
  end

  # Check if user has pending authentication
  def has_pending_authentication?
    @user.try(:authpoint_session_id).present?
  end

  # Expose OTP/push initiation for controller usage
  public :authenticate_user
end
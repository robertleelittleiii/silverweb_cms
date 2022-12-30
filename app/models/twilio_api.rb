class TwilioApi
  include Singleton

  require 'twilio-ruby'
  
  attr_accessor :client, :from_phone
  
  def self.new() 

    # put your own credentials here
    account_sid = Settings.twillo_account_sid rescue ""
    account_auth_token = Settings.twillo_auth_token rescue ""
    api_key_sid = Settings.twillo_api_key_sid rescue ""
    api_key_secret = Settings.twillo_api_key_secret rescue ""
    @from_phone = Settings.twillo_from_phone_number rescue ""
    
    # set up a client to talk to the Twilio REST API using an API Key
    if account_auth_token.blank?
      @client = Twilio::REST::Client.new api_key_sid, api_key_secret, account_sid
    else 
      @client = Twilio::REST::Client.new account_sid, account_auth_token
    end
    
  end
  
  def self.send_sms(to_phone_number, message)
    self.new
    @client.messages.create(
      from: @from_phone,
      to: to_phone_number,
      body: message
    )
  end
  
  
end
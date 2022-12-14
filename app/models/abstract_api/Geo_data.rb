class AbstractApi::GeoData
  require 'net/http'
  require 'net/https'
  
  
def self.make_request(ip_address, clean_emoji=true)
    api_key = Settings.abstract_api_key
    uri = URI("https://ipgeolocation.abstractapi.com/v1/?api_key=#{api_key}&ip_address=#{ip_address}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request =  Net::HTTP::Get.new(uri)

    response = http.request(request)
  
    return_response = JSON.parse(response.body)
    
    # clean emoji character (caused db error)
    if clean_emoji 
      return_response["flag"]["emoji"] = ""
    end
  
    puts "Status code: #{ response.code }"
    puts "Response body: #{ return_response }"
    
    return response.code, return_response
rescue StandardError => error
    puts "Error (#{ error.message })"
    return response.code, error.message
end
  
  
end
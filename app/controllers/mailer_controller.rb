class MailerController < ApplicationController
  
  protect_from_forgery :except => :simple_form

 
  def simple_form
    simple_form_params = mailer_params
    
    @subject= simple_form_params["subject"]
    @from = simple_form_params["address_from"]
    @from_name = simple_form_params["FullName"]
    
    @to= simple_form_params["address_to"]
    @redirect_to = simple_form_params["redirect"].blank? ? "/home" : simple_form_params["redirect"]
      
    @cc = simple_form_params["copy"]== "1" ? @from : ""
    
    body_field = simple_form_params.clone
    body_field.delete("copy")
    body_field.delete("send_message")
    body_field.delete("redirect")
    body_field.delete("Submit")
    body_field.delete("address_from")
    body_field.delete("address_to")
    body_field.delete("subject")
    body_field.delete("action") 
    body_field.delete("controller")
    
   # puts(body_field.inspect)
   # puts("Body field",body_field.to_yaml.to_s)
    
    response_code = body_field["g-recaptcha-response"]
    body_field.delete("g-recaptcha-response")

    requester_ip_address = request.remote_ip
    secret_server_code = Settings.google_recaptcha_private_key
    
    url = URI.parse('https://www.google.com/recaptcha/api/siteverify')
    req = Net::HTTP::Post.new(url.path)
    req.form_data = datablock  = {
      :secret=>secret_server_code, 
      :response=>response_code, 
      :remoteip=>requester_ip_address}
    
    con = Net::HTTP.new(url.host, url.port)
    con.use_ssl = true
    response = con.start {|http| http.request(req)}  
    response_parsed  = JSON.parse(response.read_body).with_indifferent_access

    if response_parsed[:success] or response_code.blank? then
      @message_body = body_field.to_yaml.split("\n")[1..-1].join("\n")

    #  puts("here", @messsage_body, @from, @to, @subject)
      @mail_item = ContactUs.send_mail(@message_body, @from, @to, @subject)
      @mail_item.deliver
    
      notice_response = "Your contact request has been sent."

    else
      notice_response = "Sorry, your request could not be sent, please try again."
      @redirect_to = request.original_url
    end
    redirect_to @redirect_to, notice: notice_response
  
    #
    #   
    #         render body: nil;
  end
  protected

  def authorize
  end

  def authenticate
  end
  
  
  def mailer_params
    params.permit!.to_hash
  end
end

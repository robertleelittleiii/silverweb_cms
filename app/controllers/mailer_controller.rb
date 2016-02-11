class MailerController < ApplicationController
  
  protect_from_forgery :except => :simple_form

 
  def simple_form
    @subject= params["subject"]
    @from= params["address_from"]
    @to= params["address_to"]
    @redirect_to = params["redirect"].blank? ? "/home" : params["redirect"]
      
    @cc = params["copy"]== "1" ? @from : ""
    
    body_field = params.clone
    body_field.delete("copy")
    body_field.delete("send_message")
    body_field.delete("redirect")
    body_field.delete("Submit")
    body_field.delete("address_from")
    body_field.delete("address_to")
    body_field.delete("subject")
    body_field.delete("action") 
    body_field.delete("controller")
    
    puts(body_field.inspect)
    puts("Body field",body_field.to_yaml.to_s)
    
    @message_body = body_field.to_yaml.split("\n")[1..-1].join("\n")

    puts("here", @messsage_body, @from, @to, @subject)
    @mail_item = ContactUs.send_mail(@message_body, @from, @to, @subject)
    @mail_item.deliver
    
    redirect_to @redirect_to, notice: "Your contact request has been sent."
    #
    #   
    #         render :nothing=>true;
  end
  protected

  def authorize
  end

  def authenticate
  end
end

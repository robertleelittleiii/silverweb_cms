class UserNotifier < ActionMailer::Base
 
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  
  default :from=>"admin@littleconsultingnj.com"

  
#  def signup_notification(user, siteurl)
#    set_up_images()
#    @hostfull=siteurl
#    setup_email(user)
#    subject 'Please activate your new account'
#    body(:user=>user, :hostfull=>@hostfull)
#    content_type "text/html"   #Here's where the magic happens
#  end
  
  
  

  def signup_notification(user, host)
    set_up_images()

    @user=user
    @hostfull=host
    @admin_email = Settings.admin_email || self.default_params[:from]
    @site_name = ("The " + Settings.company_name + " Team </br>" + link_to(Settings.company_url, "http://" + Settings.company_url )).html_safe
    @cc_emai_address = Settings.cc_email_address || ""
    mail(:from=>@admin_email, :cc=>@cc_emai_address, :to => "#{user.user_attribute.first_name} #{user.user_attribute.last_name}<#{user.name}>", :subject => "Welcome to #{Settings.company_name || "our store"}", 'Importance' => 'high', 'X-Priority' => '1')
  end
 
  
  def reset_notification(user, host)
    
    set_up_images()
    puts("Self: #{self.default_params[:from]}")
    @user=user
    @hostfull=host
    @site_name = Settings.company_url
    @admin_email = Settings.admin_email || self.default_params[:from]
    mail(:from=>@admin_email,:to => "#{user.user_attribute.first_name} #{user.user_attribute.last_name}<#{user.name}>", :subject => "Reset your password", 'Importance' => 'high', 'X-Priority' => '1')
  end
 
  
#  def signup_notification2(user, siteurl)
#    set_up_images()
#    @hostfull=siteurl
#    @site_name = Settings.company_url
#    setup_email(user)
#    subject 'Please activate your new account'
#    body(:user=>user, :hostfull=>@hostfull)
#    content_type "text/html"   #Here's where the magic happens
#  end

#  def activation(user)
#    set_up_images()
#    setup_email(user)
#    @site_name = Settings.company_url
#    @subject    += 'Your account has been activated!'
#    @body  = "#{@site_name}"
#    @site_name = Settings.company_url
#  end

#  def reset_notification2(user, siteurl)
#    set_up_images()
#    @hostfull=siteurl
#    @site_name = Settings.company_url
#    setup_email(user)
#    subject 'Link to reset your password'
#    body(:user=>user, :hostfull=>@hostfull)
#    content_type "text/html"   #Here's where the magic happens
#
#  end
#  
  def lostwithemail(user, host)
    set_up_images()
    @user=user
    @hostfull=host
    @site_name = Settings.company_url
    @admin_email = Settings.admin_email || self.default_params[:from]

    mail(:from=>@admin_email,:to => "#{user.user_attribute.first_name} #{user.user_attribute.last_name}<#{user.name}>", :subject => "Activation for #{Settings.company_name || "our store." }", 'Importance' => 'high', 'X-Priority' => '1')
  end
  
  
  
  protected

 def set_up_images
       attachments.inline['logo-100.png'] = File.read(Rails.root.to_s + '/app/assets/images/site/logo-100.png')
 end
 
#  def setup_email(user)
#    @recipients  = "#{user.name}"
#    @from        = "admin@squirtinibikini.com"
#    @subject     = "[mysite]"
#    @sent_on     = Time.now
#    @body = user.name
#  end
end
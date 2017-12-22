class ContactUs < ActionMailer::Base
  default :from => "noreply@onewhere.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contact_us.send_mail.subject
  #
  
    def send_mail (form_data, from, to, subject)
      
      @user=from
      
      from = Settings.admin_email || "noreply@onewhere.com"
    @form_data=form_data
    puts("stuff", @form_data, from, to, subject)
    mail(:to => to,:from=>from, :subject => subject, 'Importance' => 'high', 'X-Priority' => '1')
  end
end

class ContactUs < ActionMailer::Base
  default :from => "admin@squirtinibikini.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contact_us.send_mail.subject
  #
  
  def send_mail (form_data, from, to, subject)
    @form_data=form_data
    @user=from
    puts("stuff", @form_data, from, to, subject)
    mail(:to => to,:from=>from, :subject => subject)
  end
end

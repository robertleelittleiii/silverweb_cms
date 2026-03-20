class UserAttribute < ActiveRecord::Base
  belongs_to :user, optional: true

  after_save :notify_text_message_status_change, if: :saved_change_to_allow_text_messages?

  private

  def notify_text_message_status_change
    return unless user && user.formated_phone_number.present?

    if allow_text_messages
      message = "You have enabled text messaging. You can disable it by clicking the yes/no button in your preferences."
    else
      message = "Text messaging is now disabled. To enable it again, visit your preferences in the internal cloud system."
    end

    begin
      TwilioApi.send_sms(user.formated_phone_number, message)
    rescue => e
      logger.error "Failed to send text message status update: #{e.message}"
    end
  end

end


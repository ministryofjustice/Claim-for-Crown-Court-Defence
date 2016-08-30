# Preview all emails at http://localhost:3000/rails/mailers/message_notification_mailer
class MessageNotificationMailerPreview < ActionMailer::Preview

  def notify_message
    claim = Claim::BaseClaim.first
    # user = claim.creator
    MessageNotificationMailer.notify_message(claim)
  end

end

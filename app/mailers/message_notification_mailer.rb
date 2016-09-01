class MessageNotificationMailer < ApplicationMailer

  layout 'email'

  def notify_message(claim)
    @claim = claim
    @user = claim.creator
    mail(to: @user.email_with_name, subject: "You have messages on claim #{@claim.case_number}")
  end
end

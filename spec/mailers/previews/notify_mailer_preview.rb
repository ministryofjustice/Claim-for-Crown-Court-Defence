class NotifyMailerPreview < ActionMailer::Preview

  def new_message_test_email
    claim = Claim::BaseClaim.last
    NotifyMailer.new_message_test_email(claim)
  end

end

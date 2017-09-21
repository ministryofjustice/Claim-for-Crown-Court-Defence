class NotifyMailerPreview < ActionMailer::Preview

  def message_added_email
    claim = Claim::BaseClaim.active.last
    NotifyMailer.message_added_email(claim)
  end

end

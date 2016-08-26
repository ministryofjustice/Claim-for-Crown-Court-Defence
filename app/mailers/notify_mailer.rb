class NotifyMailer < GovukNotifyRails::Mailer

  # Define methods as usual, and set the template and personalisation accordingly
  # Then just use mail() as with any other ActionMailer, with the recipient email.
  # This is just an example:
  #
  def new_message_test_email(claim)
    user = claim.external_user.user

    set_template('9661d08a-486d-4c67-865e-ad976f17871d')
    set_personalisation(
      full_name: user.name,
      messages_url: external_users_claim_url(claim, messages: true)
    )

    mail(to: user.email)
  end

end

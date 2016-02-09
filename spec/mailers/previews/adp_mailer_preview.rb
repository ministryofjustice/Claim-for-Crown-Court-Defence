class AdpMailerPreview < ActionMailer::Preview

  # NOTE: confirmation instructions not required unless Devise :confirmable is implemented
  # def confirmation_instructions
  #   Devise::Mailer.confirmation_instructions(User.first, "faketoken")
  # end

  def reset_password_instructions
    AdpMailer.reset_password_instructions(User.first, "faketoken")
  end

  # NOTE: unlock instructions is not required unless locking strategy is changed to :email or :both - see config
  # def unlock_instructions
  #   Devise::Mailer.unlock_instructions(User.first, "faketoken")
  # end

end
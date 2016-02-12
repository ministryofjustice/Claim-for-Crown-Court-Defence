class AdpMailerPreview < ActionMailer::Preview

  # NOTE: confirmation instructions not required unless Devise :confirmable is implemented
  # def confirmation_instructions
  #   Devise::Mailer.confirmation_instructions(User.first, "faketoken")
  # end

  def welcome_password_instructions
    creator = FactoryGirl.create(:external_user, :advocate, :advocate_and_admin)
    advocate = FactoryGirl.create(:external_user, :advocate)
    advocate.user.email_creator = creator
    AdpMailer.reset_password_instructions(advocate.user, "faketoken")
  end

  def reset_password_instructions
    advocate = FactoryGirl.create(:external_user, :advocate)
    advocate.user.sign_in_count = 21
    AdpMailer.reset_password_instructions(advocate.user, "faketoken")
  end

  # NOTE: unlock instructions is not required unless locking strategy is changed to :email or :both - see config
  # def unlock_instructions
  #   Devise::Mailer.unlock_instructions(User.first, "faketoken")
  # end

end
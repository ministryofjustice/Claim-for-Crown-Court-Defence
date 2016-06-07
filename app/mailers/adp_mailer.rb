class AdpMailer < Devise::Mailer
  # gives access to all helpers defined within `application_helper`.
  helper :application

  # Optional. eg. `confirmation_url`
  include Devise::Controllers::UrlHelpers

  # to make sure that your mailer uses the devise views
  default template_path: 'devise/mailer'

  def reset_password_instructions(record, token, opts={})
    opts.merge!(subject: t('devise.mailer.welcome_password_instructions.subject')) if record.sign_in_count == 0
    super
  end
end

class AdpMailer < Devise::Mailer

  MAILER_ADMIN_CONTACT = 'laa-product@digital.justice.gov.uk'

  # gives access to all helpers defined within `application_helper`.
  helper :application

  # Optional. eg. `confirmation_url`
  include Devise::Controllers::UrlHelpers

  # to make sure that your mailer uses the devise views
  default template_path: 'devise/mailer'

  def reset_password_instructions(record, token, opts={})
    set_email_contact(record)
    opts.merge!(subject: t('devise.mailer.welcome_password_instructions.subject')) if record.sign_in_count == 0
    super
  end

private

  # If user is being created by a superadmin we include a specific email contact in the mail
  # otherwise we include the email of the creator of the user
  def set_email_contact(record)
    @email_contact  = if record.email_creator.persona.is_a?(SuperAdmin)
                        MAILER_ADMIN_CONTACT
                      else
                        record.email_creator.email
                      end
  rescue
    @email_contact = MAILER_ADMIN_CONTACT
  end

end

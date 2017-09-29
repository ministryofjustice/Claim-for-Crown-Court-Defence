class DeviseMailer < GovukNotifyRails::Mailer
  # gives access to all helpers defined within `application_helper`.
  helper :application
  # Optional. eg. `confirmation_url`
  include Devise::Controllers::UrlHelpers
  include ActionView::Helpers::DateHelper

  def reset_password_instructions(user, token, from)
    set_template(get_template_for(user))
    set_personalisation(
      user_full_name: user.name,
      edit_password_url: edit_password_url(user, reset_password_token: token),
      invited_by_full_name: from,
      token_expiry_days: distance_of_time_in_words(User.reset_password_within),
      password_reset_url: new_user_password_url
    )
    mail(to: user.email)
  end

  def unlock_instructions(record, token, _opts = {})
    set_template(Settings.govuk_notify.templates.unlock_instructions)
    set_personalisation(
      user_full_name: record.name,
      unlock_url: unlock_url(record, unlock_token: token)
    )
    mail(to: record.email)
  end

  private

  def get_template_for(user)
    if existing_user?(user)
      Settings.govuk_notify.templates.password_reset
    elsif external_admin?(user)
      Settings.govuk_notify.templates.send("new_external_#{external_type(user)}admin")
    else
      Settings.govuk_notify.templates.new_user
    end
  end

  def existing_user?(user)
    user.sign_in_count.positive?
  end

  def external_admin?(user)
    user.persona.admin? && user.persona_type.eql?('ExternalUser')
  end

  def external_type(user)
    if user.persona.advocate?
      'advocate_'
    elsif user.persona.litigator?
      'litigator_'
    end
  end
end

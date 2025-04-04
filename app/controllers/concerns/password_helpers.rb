module PasswordHelpers
  extend ActiveSupport::Concern

  def update_password
    user = user_for_controller_action

    if user.update_with_password(password_params[:user_attributes])
      bypass_sign_in(user)
      redirect_to signed_in_user_profile_path, notice: t('shared.password_updated')
    else
      render :change_password
    end
  end

  # devise mail backgrounding achieved via User#send_devise_notification
  def deliver_reset_password_instructions(user)
    token, enc = Devise.token_generator.generate(user.class, :reset_password_token)
    user.reset_password_token = enc
    user.reset_password_sent_at = Time.now.utc
    user.save(validate: false)
    DeviseMailer.reset_password_instructions(user, token, current_user.name).deliver_later
  rescue StandardError => e
    Rails.logger.error("DEVISE MAILER ERROR: '#{e.message}' while sending reset password mail")
  end

  private

  def user_for_controller_action
    instance_variable_get(:"@#{controller_name.singularize}").user
  end

  def params_with_temporary_password
    resource_params['user_attributes']['password'] = temporary_password
    resource_params['user_attributes']['password_confirmation'] = temporary_password
    resource_params
  end

  def password_params
    %i[email first_name last_name].each { |attribute| user_params[:user_attributes].delete(attribute) }
    user_params
  end

  def resource_params
    @resource_params ||= send(:"#{controller_name.singularize}_params")
  end

  def user_params
    @user_params ||= resource_params.slice(:user_attributes)
  end

  def temporary_password
    @temporary_password ||= SecureRandom.uuid
  end
end

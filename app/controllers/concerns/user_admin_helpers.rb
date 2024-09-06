module UserAdminHelpers
  extend ActiveSupport::Concern
  
  included do
    before_action :set_resource_params, only: :create
    before_action :set_temporary_password, only: :create
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
    @resource_params['user_attributes']['password'] = @temporary_password
    @resource_params['user_attributes']['password_confirmation'] = @temporary_password
    @resource_params
  end

  def password_params
    %i[email first_name last_name].each { |attribute| @user_params[:user_attributes].delete(attribute) }
    @user_params
  end

  def set_resource_params
    resource = controller_name.singularize
    @resource_params = send((resource + '_params').to_sym)
  end

  def set_user_params
    @user_params = @resource_params.slice(:user_attributes)
  end

  def set_temporary_password
    @temporary_password = SecureRandom.uuid
  end
end

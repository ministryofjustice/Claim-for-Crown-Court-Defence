class PasswordsController < Devise::PasswordsController
  skip_load_and_authorize_resource
  before_action { DualLogin.new(session).clear }

  protected

  def after_sending_reset_password_instructions_path_for(_resource_name)
    sign_in_path if is_navigational_format?
  end
end

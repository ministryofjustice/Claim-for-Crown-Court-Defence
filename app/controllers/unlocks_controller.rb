class UnlocksController < Devise::UnlocksController
  skip_load_and_authorize_resource

  protected

  def after_sending_unlock_instructions_path_for(_resource)
    sign_in_path if is_navigational_format?
  end

  def after_unlock_path_for(_resource)
    sign_in_path if is_navigational_format?
  end
end

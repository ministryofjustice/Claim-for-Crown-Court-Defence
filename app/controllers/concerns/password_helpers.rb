module PasswordHelpers
  extend ActiveSupport::Concern

  included do
    before_action :set_resource_params, only: :update_password
    before_action :set_user_params, only: :update_password
  end

  def update_password
    user = user_for_controller_action

    if user.update_with_password(password_params[:user_attributes])
      bypass_sign_in(user)
      redirect_to signed_in_user_profile_path, notice: t('shared.password_updated')
    else
      render :change_password
    end
  end

  private

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
end

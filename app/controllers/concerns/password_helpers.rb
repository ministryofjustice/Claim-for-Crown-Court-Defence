module PasswordHelpers
  extend ActiveSupport::Concern

  included do
    before_action :get_resource_params, only: [:create, :update_password]
    before_action :set_temporary_password, only: :create
    before_action :get_user_params, only: :update_password
  end

  def update_password
    user = user_for_controller_action

    if user.update_with_password(password_params[:user_attributes])
      sign_in(user, bypass: true)
      send_ga('event', 'password', 'updated')
      redirect_to signed_in_user_profile_path, notice: 'Password successfully updated'
    else
      render :change_password
    end
  end

  def deliver_reset_password_instructions(user)
    user.send_reset_password_instructions
  end

  private

  def user_for_controller_action
    eval("@#{controller_name.singularize}").user
  end

  def params_with_temporary_password
      @resource_params['user_attributes']['password'] = @temporary_password
      @resource_params['user_attributes']['password_confirmation'] = @temporary_password
      return @resource_params
  end

  def password_params
    [:email, :first_name, :last_name].each { |attribute| @user_params[:user_attributes].delete(attribute) }
    return @user_params
  end

  def get_resource_params
    resource = controller_name.singularize
    @resource_params = self.send((resource + '_params').to_sym)
  end

  def get_user_params
    @user_params = @resource_params.slice(:user_attributes)
  end

  def set_temporary_password
    @temporary_password = SecureRandom.uuid
  end

end

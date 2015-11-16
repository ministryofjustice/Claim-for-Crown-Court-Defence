class SuperAdmins::Admin::SuperAdminsController < SuperAdmins::Admin::ApplicationController

  include PasswordHelpers

  before_action :set_super_admin, only: [:show, :edit, :update, :change_password, :update_password]

  def show; end

  def edit; end

  def update
    if @superadmin.update(superadmin_params)
      redirect_to advocates_admin_advocates_url, notice: 'Super Administrator successfully updated'
    else
      render :edit
    end
  end

  def change_password; end

  def update_password
    user = @superadmin.user
    if user.update_with_password(password_params[:user_attributes])
      sign_in(user, bypass: true)
      redirect_to super_admins_admin_super_admin_path(@superadmin), notice: 'Password successfully updated'
    else
      render :change_password
    end
  end

  private

  def set_super_admin
    @superadmin = SuperAdmin.find(params[:id])
  end

  def superadmin_params
    params.require(:superadmin).permit(
     user_attributes: [:id, :email, :email_confirmation, :password, :password_confirmation, :current_password, :first_name, :last_name]
    )
  end

end

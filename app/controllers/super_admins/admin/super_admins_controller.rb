class SuperAdmins::Admin::SuperAdminsController < SuperAdmins::Admin::ApplicationController
  include PasswordHelpers

  before_action :set_super_admin, only: %i[show edit update change_password update_password]

  def show; end

  def edit; end

  def update
    if @super_admin.update(super_admin_params)
      redirect_to super_admins_admin_super_admin_path(@super_admin), notice: 'Super Administrator successfully updated'
    else
      render :edit
    end
  end

  def change_password; end

  # NOTE: update_password in PasswordHelper

  private

  def set_super_admin
    @super_admin = SuperAdmin.find(params[:id])
  end

  def super_admin_params
    params.require(:super_admin).permit(
      user_attributes: %i[id
                          email
                          email_confirmation
                          password
                          password_confirmation
                          current_password
                          first_name
                          last_name]
    )
  end
end

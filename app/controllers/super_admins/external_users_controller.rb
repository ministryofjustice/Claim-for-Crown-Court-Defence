class SuperAdmins::ExternalUsersController < ApplicationController

  include PasswordHelpers

  before_action :set_provider
  before_action :set_external_user,  only: [:show, :edit, :update, :change_password, :update_password]

  def show; end

  def index
    @external_users = ExternalUser.where(provider: @provider)
  end

  def new
    @external_user = ExternalUser.new(provider: @provider)
    @external_user.build_user
  end

  def create
    # downcase email_confirmation - devise will downcase the email
    params[:external_user][:user_attributes][:email_confirmation].downcase!
    @external_user = ExternalUser.new(params_with_temporary_password.merge(provider: @provider))

    if @external_user.save
      deliver_reset_password_instructions(@external_user.user)
      redirect_to super_admins_provider_external_user_path(@provider, @external_user), notice: 'User successfully created'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @external_user.update(external_user_params)
     redirect_to super_admins_provider_external_user_path(@provider, @external_user), notice: 'User successfully updated'
    else
      render :edit
    end
  end

  def change_password; end

  # NOTE: do NOT use update_password in PasswordHelper as it will
  #       require current password and then sign in as user whose
  #       password was changed and redirect to their user profile path
  def update_password
    user = @external_user.user

    if user.update(password_params[:user_attributes])
      redirect_to super_admins_provider_external_user_path(@provider, @external_user), notice: 'User password successfully updated'
    else
      render :change_password
    end
  end

  private

  def external_user_params
    params.require(:external_user).permit(
     :vat_registered,
     :supplier_number,
     roles: [],
     user_attributes: [:id, :email, :email_confirmation, :password, :password_confirmation, :first_name, :last_name]
    )
  end

  def set_external_user
    @external_user  = ExternalUser.active.find(params[:id])
  end

  def set_provider
    @provider = Provider.find(params[:provider_id])
  end

end

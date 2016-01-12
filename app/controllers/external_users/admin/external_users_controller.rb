class ExternalUsers::Admin::ExternalUsersController < ExternalUsers::Admin::ApplicationController

  include PasswordHelpers

  before_action :set_external_user, only: [:show, :edit, :update, :destroy, :change_password, :update_password]

  def index
    @external_users = current_user.persona.provider.external_users.joins(:user)
    @external_users = @external_users.where("lower(users.first_name || ' ' || users.last_name) ILIKE :term", term: "%#{params[:search]}%") if params[:search].present?
    @external_users = @external_users.ordered_by_last_name
  end

  def show; end

  def edit; end

  def change_password; end

  def new
    @external_user = ExternalUser.new
    @external_user.build_user
  end

  def create
    @external_user = ExternalUser.new(params_with_temporary_password.merge(provider_id: current_user.persona.provider.id))

    if @external_user.save
      send_ga('event', 'external_user', 'created')
      @external_user.user.send_reset_password_instructions
      redirect_to external_users_admin_external_users_url, notice: 'User successfully created'
    else
      render :new
    end
  end

  def update
    if @external_user.update(external_user_params)
      send_ga('event', 'external_user', 'updated', @external_user.id == @current_user.persona_id ? 'self' : 'other')
      redirect_to external_users_admin_external_users_url, notice: 'User successfully updated'
    else
      render :edit
    end
  end

  # NOTE: update_password in PasswordHelper

  def destroy
    @external_user.destroy
    send_ga('event', 'external_user', 'deleted')
    redirect_to external_users_admin_external_users_url, notice: 'User deleted'
  end

  private

  def set_external_user
    @external_user = ExternalUser.find(params[:id])
  end

  def external_user_params
    params.require(:external_user).permit(
     :role,
     :vat_registered,
     :supplier_number,
     user_attributes: [:id, :email, :email_confirmation, :password, :password_confirmation, :current_password, :first_name, :last_name]
    )
  end
end

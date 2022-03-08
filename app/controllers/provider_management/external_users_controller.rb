class ProviderManagement::ExternalUsersController < ApplicationController
  include PasswordHelpers

  before_action :set_provider, except: %i[find search]
  before_action :set_external_user, only: %i[show edit update change_password update_password]
  before_action :external_user_by_email, only: %i[search]

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
      redirect_to_show_page(notice: I18n.t('provider_management.external_users.create.success_message'))
    else
      render :new
    end
  end

  def edit; end

  def find; end

  def search
    if @external_user&.is_a?(ExternalUser)
      redirect_to provider_management_provider_external_user_path(@external_user.provider, @external_user)
    else
      redirect_to provider_management_external_users_find_path,
                  alert: I18n.t('provider_management.external_users.search.failed_message')
    end
  end

  def update
    if @external_user.update(external_user_params)
      redirect_to_show_page(notice: I18n.t('provider_management.external_users.update.success_message'))
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
      redirect_to_show_page(notice: I18n.t('provider_management.external_users.change_password.success_message'))
    else
      render :change_password
    end
  end

  def confirmation
    if @external_user.active?
      render :disable_confirmation
    else
      render :enable_confirmation
    end
  end

  def update_available
    ActiveRecord::Type::Boolean.new.cast(params[:available]) ? enable : disable
  end

  def enable
    if (@external_user.provider == @provider) && @external_user.softly_deleted? && @external_user.un_soft_delete
      redirect_to_show_page(notice: I18n.t('provider_management.external_users.enable_confirmation.success_message'))
    else
      redirect_to_show_page(alert: I18n.t('provider_management.external_users.enable_confirmation.failed_message'))
    end
  end

  def disable
    if (@external_user.provider == @provider) && @external_user.active? && @external_user.soft_delete
      redirect_to_show_page(notice: I18n.t('provider_management.external_users.disable_confirmation.success_message'))
    else
      redirect_to_show_page(alert: I18n.t('provider_management.external_users.disable_confirmation.failed_message'))
    end
  end

  private

  def external_user_params
    params.require(:external_user).permit(
      :vat_registered,
      :supplier_number,
      roles: [],
      user_attributes: %i[id email email_confirmation password password_confirmation first_name last_name]
    )
  end

  def set_external_user
    @external_user = ExternalUser.find(params[:id])
  end

  def external_user_by_email
    @external_user = User.active.find_by(email: params[:external_user][:email])&.persona
  end

  def set_provider
    @provider = Provider.find(params[:provider_id])
  end

  def redirect_to_show_page(**kwargs)
    redirect_to provider_management_provider_external_user_path(@provider, @external_user), **kwargs
  end
end

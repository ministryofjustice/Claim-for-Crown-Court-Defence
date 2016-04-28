class ExternalUsers::Admin::ProvidersController < ExternalUsers::Admin::ApplicationController
  include ProviderAdminConcern

  def show; end

  def edit; end

  def regenerate_api_key
    @provider.regenerate_api_key!
    send_ga('event', 'api-key', 'updated')
    redirect_to external_users_admin_provider_path(@provider), notice: 'API key successfully updated'
  end

  def update
    if @provider.update(provider_params.except(*filtered_params))
      send_ga('event', 'provider', 'updated')
      redirect_to external_users_admin_provider_path, notice: 'Provider successfully updated'
    else
      render :edit
    end
  end

  private

  def set_provider
    @provider = current_user.persona.provider
  end

  def filtered_params
    [:roles]
  end

end

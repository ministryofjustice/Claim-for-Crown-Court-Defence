class Advocates::Admin::ProvidersController < Advocates::Admin::ApplicationController

  before_action :set_provider, only: [:show, :edit, :update, :regenerate_api_key]

  def show; end

  def edit; end

  def regenerate_api_key
    @provider.regenerate_api_key!
    send_ga('event', 'api-key', 'updated')
    redirect_to advocates_admin_provider_path(@provider), notice: 'API key successfully updated'
  end

  def update
    if @provider.update(provider_params)
      send_ga('event', 'provider', 'updated')
      redirect_to advocates_admin_provider_path, notice: "#{@provider.provider_type.humanize} successfully updated"
    else
      render :edit
    end
  end

  private

  def set_provider
    @provider = current_user.persona.provider
  end

  def provider_params
    params.require(:provider).permit(
     :name,
     :provider_type,
     :supplier_number,
     :vat_registered,
     :api_key
    )
  end
end

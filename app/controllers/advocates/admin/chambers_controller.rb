class Advocates::Admin::ChambersController < Advocates::Admin::ApplicationController

  before_action :set_chamber, only: [:show, :edit, :update, :regenerate_api_key]

  def show; end

  def edit; end

  def regenerate_api_key
    @chamber.regenerate_api_key!
    send_ga('event', 'api-key', 'updated')
    redirect_to advocates_admin_chamber_path(@chamber), notice: 'API key successfully updated'
  end

  def update
    if @chamber.update(chamber_params)
      send_ga('event', 'chamber', 'updated')
      redirect_to advocates_admin_chamber_path, notice: 'Chamber successfully updated'
    else
      render :edit
    end
  end

  private

  def set_chamber
    @chamber = current_user.persona.chamber
  end

  def chamber_params
    params.require(:chamber).permit(
     :name,
     :supplier_number,
     :vat_registered,
     :api_key
    )
  end
end

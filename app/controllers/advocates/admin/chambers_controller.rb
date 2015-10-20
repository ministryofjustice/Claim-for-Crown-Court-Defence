class Advocates::Admin::ChambersController < Advocates::Admin::ApplicationController

  before_action :set_chamber, only: [:show, :edit, :update]

  def show; end

  def edit; end

  def update
    if @chamber.update(chamber_params)
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
     :vat_registered
    )
  end

end
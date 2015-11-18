class SuperAdmins::ChambersController < ApplicationController

  def show
    @chamber = Chamber.find(params[:id])
  end

  def index
    @chambers = Chamber.all
  end

  def new
    @chamber = Chamber.new
  end

  def create
    @chamber = Chamber.new(chamber_params)
    if @chamber.save
      redirect_to super_admins_root_path, notice: 'Chamber successfully created'
    else
      render :new
    end
  end

private

  def chamber_params
    params.require(:chamber).permit(
      :name,
      :supplier_number,
      :vat_registered
      )
  end

end

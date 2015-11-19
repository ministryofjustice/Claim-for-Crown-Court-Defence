class SuperAdmins::ChambersController < ApplicationController


  before_action :set_chamber, only: [:show, :edit, :update]

  def show; end

  def index
    @chambers = Chamber.all
  end

  def new
    @chamber = Chamber.new
  end

  def edit; end

  def update
    if @chamber.update(chamber_params)
     redirect_to super_admins_chamber_path(@chamber), notice: 'Chamber successfully updated'
    else
      render :edit
    end
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

  def set_chamber
    @chamber = Chamber.find(params[:id])
  end

end

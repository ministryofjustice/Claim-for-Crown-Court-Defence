class SuperAdmins::ProvidersController < ApplicationController
  before_action :set_provider, only: [:show, :edit, :update]

  def show; end

  def index
    @providers = Provider.order(name: :asc) 
  end

  def new
    @provider = Provider.new
  end

  def edit; end

  def update
    if @provider.update(provider_params.except(:provider_type))
     redirect_to super_admins_provider_path(@provider), notice: 'Provider successfully updated'
    else
      render :edit
    end
  end

  def create
    @provider = Provider.new(provider_params)
    if @provider.save
      redirect_to super_admins_root_path, notice: 'Provider successfully created'
    else
      render :new
    end
  end

  private

  def provider_params
    params.require(:provider).permit(
      :name,
      :provider_type,
      :supplier_number,
      :vat_registered,
      roles: []
      )
  end

  def set_provider
    @provider = Provider.find(params[:id])
  end
end

class SuperAdmins::ProvidersController < ApplicationController
  include ProviderAdminConcern

  def show; end

  def edit; end

  def index
    @providers = Provider.order(name: :asc) 
  end

  def new
    @provider = Provider.new
  end

  def update
    if @provider.update(provider_params)
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

  def set_provider
    @provider = Provider.find(params[:id])
  end

end

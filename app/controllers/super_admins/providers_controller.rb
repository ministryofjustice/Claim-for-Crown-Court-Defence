class SuperAdmins::ProvidersController < ApplicationController
  include ProviderAdminConcern

  def index
    @providers = Provider.order(name: :asc)
  end

  def new
    @provider = Provider.new
    render 'shared/providers/new'
  end

  def edit
    render 'shared/providers/edit'
  end

  def update
    if @provider.update(provider_params.except(*filtered_params))
      @provider.remove_lgfs_supplier_numbers_if_chamber
      redirect_to super_admins_provider_path(@provider), notice: 'Provider successfully updated'
    else
      render 'shared/providers/edit'
    end
  end

  def create
    @provider = Provider.new(provider_params)
    if @provider.save
      redirect_to super_admins_root_path, notice: 'Provider successfully created'
    else
      render 'shared/providers/new'
    end
  end

  private

  def set_provider
    @provider = Provider.find(params[:id])
  end

  def filtered_params
    []
  end
end

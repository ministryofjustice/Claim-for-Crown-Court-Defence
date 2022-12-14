class ProviderManagement::ProvidersController < ApplicationController
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

  def create
    @provider = Provider.new(provider_params)
    if @provider.save
      redirect_to provider_management_root_path, notice: 'Provider successfully created'
    else
      @error_presenter = error_presenter
      render 'shared/providers/new'
    end
  end

  def update
    if @provider.update(provider_params.except(*filtered_params))
      redirect_to provider_management_provider_path(@provider), notice: 'Provider successfully updated'
    else
      @error_presenter = error_presenter
      render 'shared/providers/edit'
    end
  end

  private

  def set_provider
    @provider = Provider.find(params[:id])
  end

  def filtered_params
    []
  end

  def error_presenter
    ErrorMessage::Presenter.new(@provider, ErrorMessage.translation_file_for('provider'))
  end
end

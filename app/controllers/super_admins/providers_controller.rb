class SuperAdmins::ProvidersController < ApplicationController
  include ProviderAdminConcern

  def index; end

  private

  def filtered_params
    []
  end
end

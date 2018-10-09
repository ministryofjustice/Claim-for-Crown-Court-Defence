class MaintenanceController < ApplicationController
  skip_load_and_authorize_resource
  skip_before_action :handle_maintenance

  before_action :redirect_if_maintenance_mode_disabled

  def show
    render :show, status: 503
  end

  def redirect_if_maintenance_mode_disabled
    redirect_back_or(root_path_url_for_user) unless maintenance_mode?
  end
end

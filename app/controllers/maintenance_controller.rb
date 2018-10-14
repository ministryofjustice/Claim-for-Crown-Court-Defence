class MaintenanceController < ApplicationController
  skip_load_and_authorize_resource

  def index
    respond_to do |format|
      format.html { render :index, status: 503 }
      format.json { render json: { status: 503, message: 'maintenance mode enabled' } }
      format.all { render status: 503, plain: 'service unavailable' }
    end
  end
end

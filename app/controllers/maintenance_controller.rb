class MaintenanceController < ApplicationController
  protect_from_forgery prepend: true, except: :index
  skip_load_and_authorize_resource only: :index

  def index
    response.set_header('Retry-After', MaintenanceMode.retry_after)
    respond_to do |format|
      format.html { render :index, status: 503 }
      format.json { render json: { status: 503, message: 'maintenance mode enabled' } }
      format.all { render status: 503, plain: 'service unavailable' }
    end
  end
end

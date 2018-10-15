class ErrorsController < ApplicationController
  skip_load_and_authorize_resource only: %i[
    not_endpoint
    not_found
    internal_server_error
    service_unavailable
    dummy_exception
  ]
  protect_from_forgery prepend: true, except: %i[
    not_endpoint
    not_found
    internal_server_error
    service_unavailable
  ]

  def not_endpoint
    logger.info("Data POSTed to root with API key: #{not_endpoint_params[:api_key]}") if params.present?
    render status: 403, plain: 'Not a valid api endpoint'
  end

  def not_found
    respond_to do |format|
      format.html { render status: 404 }
      format.all { render status: 404, plain: 'not found' }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: 500 }
      format.all { render status: 500, plain: 'internal server error' }
    end
  end

  def service_unavailable
    respond_to do |format|
      format.html { render status: 503 }
      format.all { render status: 503, plain: 'service unavailable' }
    end
  end

  def dummy_exception
    raise ArgumentError, "This exception has been raised as a test by going to the 'dummy_exception' endpoint."
  end

  private

  def not_endpoint_params
    params.permit(:api_key)
  end
end

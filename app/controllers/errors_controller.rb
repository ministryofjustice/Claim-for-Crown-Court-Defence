class ErrorsController < ApplicationController
  skip_load_and_authorize_resource only: [:not_found, :internal_server_error, :dummy_exception]
  protect_from_forgery except: [:not_found, :internal_server_error]

  def not_found
    respond_to do |format|
      format.html { render status: 404 }
      format.all { render status: 404, text: 'not found' }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: 500 }
      format.all { render status: 500, text: 'error' }
    end
  end

  def dummy_exception
    raise ArgumentError, "This exception has been raised as a test by going to the 'dummy_exception' endpoint."
  end
end

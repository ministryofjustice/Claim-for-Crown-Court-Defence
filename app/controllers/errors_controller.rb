class ErrorsController < ApplicationController
  skip_load_and_authorize_resource only: [:not_found, :internal_server_error]
  respond_to :html

  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end

  def dummy_exception
    raise ArgumentError.new("This exception has been raised as a test by going to the 'dummy_exception' endpoint.")
  end

end

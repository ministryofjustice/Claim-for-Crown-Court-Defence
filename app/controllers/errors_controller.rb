class ErrorsController < ApplicationController
  skip_load_and_authorize_resource only: [:not_found, :internal_server_error]
  respond_to :html

  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end
end

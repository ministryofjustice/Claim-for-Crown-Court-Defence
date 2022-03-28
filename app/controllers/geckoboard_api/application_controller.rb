class GeckoboardAPI::ApplicationController < ActionController::Base
  before_action :authenticate_token!

  private

  def authenticate_token!
    return if request.format.html? # open access for html
    return if params[:token] == ENV.fetch('GECKOBOARD_TOKEN', nil) || %w[test development].include?(Rails.env)
    render json: { error: 'Unauthorised' }, status: :unauthorized
  end
end

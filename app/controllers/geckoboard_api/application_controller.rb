class GeckoboardApi::ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception
  before_action :authenticate_token!

  private

  def authenticate_token!
    return if request.format.html? # open access for html
    return if params[:token] == ENV['GECKOBOARD_TOKEN'] || %w[test development].include?(Rails.env)
    render json: { error: 'Unauthorised' }, status: :unauthorized
  end
end

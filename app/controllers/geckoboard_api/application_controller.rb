class GeckoboardApi::ApplicationController < ActionController::Base
  before_action :authenticate_token!

  private

  def authenticate_token!
    unless params[:token] == ENV['GECKOBOARD_TOKEN'] || %w(test development).include?(Rails.env)
      render json: { error: 'Unauthorised' }, status: :unauthorized
    end
  end
end

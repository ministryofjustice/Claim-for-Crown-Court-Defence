class GeckoboardApi::ApplicationController < ActionController::Base
  before_action :authenticate_token!

  private

  def authenticate_token!
    unless params[:token] == '1234' #ENV['GECKOBOARD_TOKEN']
      render json: { error: 'Unauthorised' }, status: :unauthorized
    end
  end
end

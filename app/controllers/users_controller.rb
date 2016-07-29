class UsersController < ApplicationController

  def update_settings
    @result = current_user.save_settings!(settings_params)
    respond_to :js
  end

  private

  def settings_params
    params.except(:id).permit(:api_promo_seen)
  end
end

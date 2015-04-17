class Admin::ApplicationController < ApplicationController
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    unless user_signed_in? && current_user.admin?
      redirect_to root_url, alert: 'Must be signed in as an admin'
    end
  end
end

class Advocates::DashboardController < ApplicationController
  def index
    @claims = current_user.claims_created.order(created_at: :desc)
  end
end

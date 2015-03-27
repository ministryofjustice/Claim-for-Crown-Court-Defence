class CaseWorkers::DashboardController < ApplicationController
  def index
    @claims = Claim.order(created_at: :desc)
  end
end

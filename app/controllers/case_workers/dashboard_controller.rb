class CaseWorkers::DashboardController < CaseWorkers::ApplicationController
  def index
    @claims = Claim.order(created_at: :desc)
  end
end

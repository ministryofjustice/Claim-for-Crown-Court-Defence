class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show]

  def index
    @claims = current_user.claims_to_manage.order(submitted_at: :desc)
  end

  def show; end

  private

  def set_claim
    @claim = Claim.find(params[:id])
  end
end

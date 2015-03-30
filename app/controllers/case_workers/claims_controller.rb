class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show, :edit, :summary, :update, :destroy]

  def index
    @claims = Claim.order(created_at: :desc)
  end

  def show; end

  private

  def set_claim
    @claim = Claim.find(params[:id])
  end
end

class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show]

  def index
    @claims = current_user.claims_to_manage.order("#{sort_column} #{sort_direction}")
  end

  def show; end

  private

  def set_claim
    @claim = Claim.find(params[:id])
  end

  def sort_column
    Claim.column_names.include?(params[:sort]) ? params[:sort] : 'submitted_at'
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
  end
end

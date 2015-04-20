class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show]

  def index
    @claims = case tab
      when 'current'
        current_user.claims_to_manage.submitted
      when 'completed'
        current_user.claims_to_manage.completed
    end

    if params[:search].present?
      @claims = @claims.find_by_maat_reference(params[:search])
    end

    @claims = @claims.order("#{sort_column} #{sort_direction}")
  end

  def show; end

  private

  def set_claim
    @claim = Claim.find(params[:id])
  end

  def tab
    %w(current completed).include?(params[:tab]) ? params[:tab] : 'current'
  end

  def sort_column
    Claim.column_names.include?(params[:sort]) ? params[:sort] : 'submitted_at'
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
  end
end

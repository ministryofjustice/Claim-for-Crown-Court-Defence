class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  respond_to :html
  before_action :set_claims, only: [:index]
  before_action :set_claim, only: [:show]

  def index
    @claims = @claims.find_by_maat_reference(params[:search_maat]) if params[:search_maat].present?
    @claims = @claims.find_by_defendant_name(params[:search_defendant]) if params[:search_defendant].present?
    @claims = @claims.order("#{sort_column} #{sort_direction}")
  end

  def show
    @doc_types = DocumentType.all
    @messages = @claim.messages.most_recent_first
    @message = @claim.messages.build
  end

  private

  def set_claims
    @claims = case tab
      when 'current'
        current_user.claims.allocated
      when 'completed'
        current_user.claims.completed
    end
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

  def set_claim
    @claim = Claim.find(params[:id])
  end
end

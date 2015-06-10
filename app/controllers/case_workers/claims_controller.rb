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

  def update
    @claim = Claim.find(params[:id])
    @messages = @claim.messages.most_recent_first
    @doc_types = DocumentType.all
    begin
      @claim.update_model_and_transition_state(claim_params)
    rescue StateMachine::InvalidTransition => err
    end
    @message = @claim.messages.build
    render action: :show
  end

  private

  def claim_params
    params.require(:claim).permit(:state_for_form, :amount_assessed, :additional_information)
  end

  def set_claims
    if current_user.persona.admin?
      @claims = case tab
        when 'allocated'
          Claim.allocated
        when 'unallocated'
          Claim.submitted
      end
    else
      @claims = case tab
        when 'current'
          current_user.claims.allocated
        when 'completed'
          current_user.claims.completed
      end
    end
  end

  def tab
    if current_user.persona.admin?
      %w(allocated unallocated).include?(params[:tab]) ? params[:tab] : 'allocated'
    else
      %w(current completed).include?(params[:tab]) ? params[:tab] : 'current'
    end
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

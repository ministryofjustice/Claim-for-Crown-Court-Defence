class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  respond_to :html
  before_action :set_claims, only: [:index]
  before_action :set_claim, only: [:show]
  before_action :set_search_options, only: [:index]
  before_action :set_claim_ids_and_count, only: [:show]

  def index
    add_breadcrumb 'Dashboard', case_workers_root_path

    search if params[:search].present?
    @claims = @claims.order("#{sort_column} #{sort_direction}")
  end

  def show
    add_breadcrumb 'Dashboard', case_workers_root_path
    add_breadcrumb "Claim: #{@claim.case_number}", case_workers_claim_path(@claim)

    @doc_types = DocType.all
    @messages = @claim.messages.most_recent_first
    @message = @claim.messages.build
  end

  def update
    @claim = Claim.find(params[:id])
    @messages = @claim.messages.most_recent_first
    @doc_types = DocType.all
    begin
      @claim.update_model_and_transition_state(claim_params)
    rescue StateMachine::InvalidTransition => err
    end
    @message = @claim.messages.build
    render action: :show
  end

  private

  def set_claim_ids_and_count
    @claim_ids = params[:claim_ids] if params[:claim_ids].present?
    @claim_count = params[:claim_count] if params[:claim_count].present?
  end

  def search
    params[:search_field] ||= 'All'
    @claims = @claims.search(*search_option_mappings[params[:search_field]], params[:search])
  end

  def search_option_mappings
    option_mappings = {
      'All' => [:maat_reference, :defendant_name],
      'MAAT Reference' => [:maat_reference],
      'Defendant' => [:defendant_name],
      'Case worker' => [:case_worker_name_or_email]
    }

    option_mappings['All'] << :case_worker_name_or_email if current_user.persona.admin?
    option_mappings
  end

  def claim_params
    params.require(:claim).permit(
      :state_for_form,
      :amount_assessed,
      :additional_information,
      :notes
    )
  end

  def set_claims
    if current_user.persona.admin?
      @claims = case tab
        when 'allocated'
          Claim.caseworker_dashboard_under_assessment
        when 'unallocated'
          Claim.submitted
        when 'completed'
          Claim.caseworker_dashboard_completed
      end
    else
      @claims = case tab
        when 'current'
          current_user.claims.caseworker_dashboard_under_assessment
        when 'completed'
          current_user.claims.caseworker_dashboard_completed
      end
    end
  end

  def tab
    if current_user.persona.admin?
      %w(allocated unallocated completed).include?(params[:tab]) ? params[:tab] : 'allocated'
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

  def set_search_options
    if current_user.persona.admin?
      @search_options = ['All', 'MAAT Reference', 'Defendant', 'Case worker']
    else
      @search_options = ['All', 'MAAT Reference', 'Defendant']
    end
  end
end

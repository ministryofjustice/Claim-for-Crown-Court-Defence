class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  include DocTypes

  respond_to :html
  before_action :set_claims,          only: [:index, :archived]
  before_action :set_search_options,  only: [:index, :archived]
  before_action :filter_claims,       only: [:index, :archived]
  before_action :set_claim, only: [:show]
  before_action :set_doctypes, only: [:show, :update]

  include ReadMessages

  def index
  end

  def archived
  end

  def show
    ap params
    @claim.assessment = Assessment.new if @claim.assessment.nil?
    @enable_assessment_input = @claim.assessment.blank?
    @enable_status_change = true

    @doc_types = DocType.all
    @messages = @claim.messages.most_recent_last
    @message = @claim.messages.build
    
  end

  def update
    ap params
    @claim = Claim.find(params[:id])
    @messages = @claim.messages.most_recent_last
    @doc_types = DocType.all

    begin
      @claim.update_model_and_transition_state(claim_params)
    rescue StateMachines::InvalidTransition => err
    end
    @enable_status_change = true
    @message = @claim.messages.build
    redirect_to case_workers_claim_path
  end

  private

  def set_claim_ids_and_count
    session[:claim_ids] = @claims.all.map(&:id)
    session[:claim_count] = @claims.try(:count)
  end

  def search(states=nil)
    @claims = @claims.search(params[:search], states, *search_options)
  end

  def search_options
    options = [:maat_reference, :defendant_name]
    options << :case_worker_name_or_email if current_user.persona.admin?
    options
  end

  def claim_params
    params.require(:claim).permit(
      :state_for_form,
      :additional_information,
      :assessment_attributes => [
        :id,
        :fees,
        :expenses
      ],
      :redeterminations_attributes => [
        :id,
        :fees,
        :expenses
      ]
    )
  end

  def set_claims
    if current_user.persona.admin?
      @claims = case tab
        when 'current'
          current_user.claims.caseworker_dashboard_under_assessment
        when 'archived'
          Claim.caseworker_dashboard_archived
        when 'allocated'
          Claim.caseworker_dashboard_under_assessment
        when 'unallocated'
          Claim.submitted_or_redetermination_or_awaiting_written_reasons

        # TODO: no longer used? - remove
        when 'completed'
          Claim.caseworker_dashboard_completed

      end
    else
      @claims = case tab
        when 'current'
          current_user.claims.caseworker_dashboard_under_assessment
        when 'archived'
          current_user.claims.caseworker_dashboard_archived

        # TODO: no longer used? - remove
        when 'completed'
          current_user.claims.caseworker_dashboard_completed
      end
    end
  end

  def tab
    if current_user.persona.admin?
      %w(allocated unallocated current archived completed).include?(params[:tab]) ? params[:tab] : 'allocated'
    else
      %w(current archived completed).include?(params[:tab]) ? params[:tab] : 'current'
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

  def filter_claims
    search if params[:search].present?
    @claims = @claims.order("#{sort_column} #{sort_direction}")
    set_claim_ids_and_count
  end

end

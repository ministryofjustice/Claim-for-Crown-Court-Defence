class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  include DocTypes

  helper_method :sort_column, :sort_direction

  respond_to :html

  # callback order is important (must set claims before filtering and sorting)
  before_action :set_claims,              only: [:index, :archived]
  before_action :filter_current_claims,   only: [:index]
  before_action :filter_archived_claims,  only: [:archived]
  before_action :sort_claims,             only: [:index, :archived]

  before_action :set_claim, only: [:show]
  before_action :set_doctypes, only: [:show, :update]

  include ReadMessages
  include MessageControlsDisplay

  def index
  end

  def archived
  end

  def show
    @claim.assessment = Assessment.new if @claim.assessment.nil?
    @enable_assessment_input = @claim.assessment.blank? && @claim.state == 'allocated'

    @doc_types = DocType.all
    @messages = @claim.messages.most_recent_last
    @message = @claim.messages.build

  end

  def update
    @claim = Claim.find(params[:id])
    @messages = @claim.messages.most_recent_last
    @doc_types = DocType.all

    begin
      @claim.update_model_and_transition_state(claim_params)
    rescue StateMachines::InvalidTransition => err
    end
    @enable_status_change = true
    @message = @claim.messages.build
    redirect_to case_workers_claim_path(errors: @claim.errors.full_messages)
  end

  private

  def set_claim_carousel_info
    session[:claim_ids] = @claims.all.map(&:id)
    session[:claim_count] = @claims.try(:size)
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
      end
    else
      @claims = case tab
        when 'current'
          current_user.claims.caseworker_dashboard_under_assessment
        when 'archived'
          current_user.claims.caseworker_dashboard_archived
      end
    end
  end

  def tab
    if current_user.persona.admin?
      %w(allocated unallocated current archived).include?(params[:tab]) ? params[:tab] : 'allocated'
    else
      %w(current archived).include?(params[:tab]) ? params[:tab] : 'current'
    end
  end

  def set_claim
    @claim = Claim.find(params[:id])
  end

  def filter_current_claims
    search(Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES) if params[:search].present?
  end

  def filter_archived_claims
    search(Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES) if params[:search].present?
  end

  def sort_column
    @claims.sortable_by?(params[:sort]) ? params[:sort] : 'last_submitted_at'
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def sort_and_paginate
    # GOTCHA: must paginate in same call that sorts/orders
    @claims = @claims.sort(sort_column, sort_direction).page(params[:page]).per(10)
  end

  def sort_claims
    sort_and_paginate
    set_claim_carousel_info
  end

end

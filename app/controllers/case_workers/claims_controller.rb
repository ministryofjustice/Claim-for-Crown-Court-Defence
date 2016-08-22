class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  include PaginationHelpers
  include DocTypes

  skip_load_and_authorize_resource
  authorize_resource class: Claim::BaseClaim

  helper_method :sort_column, :sort_direction

  respond_to :html

  # callback order is important (must set claims before filtering and sorting)
  before_action :set_claims,              only: [:index, :archived]
  before_action :filter_current_claims,   only: [:index]
  before_action :filter_archived_claims,  only: [:archived]
  before_action :sort_claims,             only: [:index, :archived]

  before_action :set_claim, only: [:show, :messages]
  before_action :set_doctypes, only: [:show, :update]

  include ReadMessages
  include MessageControlsDisplay

  def index
  end

  def archived
  end

  def show
    prepare_show_action
  end

  def messages
    render template: 'messages/claim_messages'
  end

  def update
    updater = Claims::CaseWorkerClaimUpdater.new(params[:id], claim_params).update!
    @claim = updater.claim
    @doc_types = DocType.all
    if updater.result == :ok
      redirect_to case_workers_claim_path(params.slice(:messages))
    else
      @claim.errors
      prepare_show_action
      render :show
    end
  end

  private

  def prepare_show_action
    @claim.assessment = Assessment.new if @claim.assessment.nil?
    @doc_types = DocType.all
    @messages = @claim.messages.most_recent_last
    @message = @claim.messages.build
  end

  def search(states=nil)
    @claims = @claims.search(params[:search], states, *search_options)
  end

  def search_options
    options = [:case_number, :maat_reference, :defendant_name]
    options << :case_worker_name_or_email if current_user.persona.admin?
    options
  end

  def claim_params
    params.require(:claim).permit(
      :state,
      :additional_information,
      :assessment_attributes => [
        :id,
        :fees,
        :expenses,
        :disbursements,
        :vat_amount
      ],
      :redeterminations_attributes => [
        :id,
        :fees,
        :expenses,
        :disbursements,
        :vat_amount
      ]
    ).merge(params.permit(:state_reason))
  end

  def set_claims
    if current_user.persona.admin?
      @claims = case tab
                when 'current'
                  current_user.claims.caseworker_dashboard_under_assessment
                when 'archived'
                  Claim::BaseClaim.active.caseworker_dashboard_archived
                when 'allocated'
                  Claim::BaseClaim.active.caseworker_dashboard_under_assessment
                when 'unallocated'
                  Claim::BaseClaim.active.submitted_or_redetermination_or_awaiting_written_reasons
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
    @claim = Claim::BaseClaim.active.find(params[:id])
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
    @claims = @claims.sort(sort_column, sort_direction).page(current_page).per(page_size)
  end

  def sort_claims
    sort_and_paginate
    set_claim_carousel_info
  end

end

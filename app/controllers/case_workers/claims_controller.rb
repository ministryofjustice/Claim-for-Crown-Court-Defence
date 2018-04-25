class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  include PaginationHelpers

  skip_load_and_authorize_resource
  authorize_resource class: Claim::BaseClaim

  helper_method :sort_column, :sort_direction, :search_terms

  respond_to :html

  # callback order is important (must set claims before filtering and sorting)
  before_action :set_claims,              only: %i[index archived]
  before_action :filter_current_claims,   only: [:index]
  before_action :filter_archived_claims,  only: [:archived]
  before_action :sort_claims,             only: %i[index archived]
  before_action :set_claim, only: %i[show messages publish enquire download_zip]

  include ReadMessages
  include MessageControlsDisplay

  def index; end

  def archived; end

  def show
    prepare_show_action
  end

  def download_zip
    zipper = S3ZipDownloader.new(@claim)
    zip_file = zipper.generate!

    send_file zip_file,
              filename: "#{@claim.case_number}-documents.zip",
              type: 'application/zip',
              disposition: 'attachment'
  end

  def messages
    render template: 'messages/claim_messages'
  end

  def update
    updater = Claims::CaseWorkerClaimUpdater.new(params[:id], claim_params.merge(current_user: current_user)).update!
    @claim = updater.claim
    if updater.result == :ok
      redirect_to case_workers_claim_path(permitted_params)
    else
      @error_presenter = ErrorPresenter.new(@claim)
      prepare_show_action
      render :show
    end
  end

  private

  def permitted_params
    params.permit(:messages)
  end

  def prepare_show_action
    @claim.assessment = Assessment.new if @claim.assessment.nil?
    @messages = @claim.messages.most_recent_last
    @message = @claim.messages.build
  end

  def search(states = nil)
    @claims = @claims.search(search_terms, states, *search_options) unless @claims.remote?
  end

  def claim_params
    params.require(:claim).permit(
      :state,
      :refuse_reason_text,
      :reject_reason_text,
      :additional_information,
      assessment_attributes: %i[
        id
        fees
        expenses
        disbursements
        vat_amount
      ],
      redeterminations_attributes: %i[
        id
        fees
        expenses
        disbursements
        vat_amount
      ]
    ).merge(params.permit(state_reason: []))
    # the state_reason needs to be merged because the collection_check_boxes control on the view requires
    # a claim object to render.  Because state_reason does not belong to claim, it refuses to render and
    # therefore nil is passed to the object.  This then comes back outside of the claim namespace and has
    # to be manually merged.
  end

  def set_claims
    @claims = Claims::CaseWorkerClaims.new(current_user: current_user, action: tab, criteria: criteria_params).claims
  end

  # Only these 2 actions are handle in this controller. Rest of actions in the admin-namespaced controller.
  def tab
    %w[current archived].include?(params[:tab]) ? params[:tab] : 'current'
  end

  def set_claim
    @claim = Claim::BaseClaim.active.find(params[:id])
  end

  def filter_current_claims
    search(Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES) if search_terms.present?
  end

  def filter_archived_claims
    search(Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES) if search_terms.present?
  end

  def sort_column
    params[:sort].blank? ? 'last_submitted_at' : params[:sort]
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def search_terms
    params[:search]
  end

  def sort_and_paginate
    # GOTCHA: must paginate in same call that sorts/orders
    @claims = @claims.sort_using(sort_column, sort_direction).page(current_page).per(page_size) unless @claims.remote?
  end

  def sort_claims
    sort_and_paginate
    add_claim_carousel_info
  end

  def criteria_params
    { sorting: sort_column, direction: sort_direction, page: current_page, limit: page_size, search: search_terms }
  end
end

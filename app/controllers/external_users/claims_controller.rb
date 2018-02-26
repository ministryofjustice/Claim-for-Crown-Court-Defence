class ExternalUsers::ClaimsController < ExternalUsers::ApplicationController
  # This performs magic
  include PaginationHelpers
  include DocTypes

  skip_load_and_authorize_resource

  helper_method :sort_column, :sort_direction, :scheme

  respond_to :html

  before_action :set_user_and_provider
  before_action :set_claims_context, only: %i[index archived outstanding authorised]
  before_action :set_financial_summary, only: %i[index outstanding authorised]
  before_action :initialize_json_document_importer, only: [:index]

  before_action :set_and_authorize_claim, only: %i[show edit update unarchive clone_rejected destroy summary
                                                   confirmation show_message_controls messages disc_evidence]
  before_action :set_form_step, only: %i[edit]
  before_action :set_doctypes, only: [:show]
  before_action :generate_form_id, only: %i[new edit]
  before_action :initialize_submodel_counts

  include ReadMessages
  include MessageControlsDisplay

  def index
    track_visit(url: 'external_user/claims', title: 'Your claims')

    @claims = @claims_context.dashboard_displayable_states
    search if params[:search].present?
    sort_and_paginate(column: 'last_submitted_at', direction: 'asc')
  end

  def archived
    @claims = @claims_context.archived_pending_delete
    search(:archived_pending_delete) if params[:search].present?
    sort_and_paginate(column: 'last_submitted_at', direction: 'desc')
  end

  def outstanding
    @claims = @financial_summary.outstanding_claims
    sort_and_paginate(column: 'last_submitted_at', direction: 'asc')
    @total_value = @financial_summary.total_outstanding_claim_value
  end

  def authorised
    @claims = @financial_summary.authorised_claims
    sort_and_paginate(column: 'last_submitted_at', direction: 'desc')
    @total_value = @financial_summary.total_authorised_claim_value
  end

  def messages
    render template: 'messages/claim_messages'
  end

  def show
    @messages = @claim.messages.most_recent_last
    @message = @claim.messages.build

    track_visit({
                  url: 'external_user/%{type}/claim/show',
                  title: 'Show %{type} claim details'
                }, claim_tracking_substitutions)
  end

  def summary
    track_visit({
                  url: 'external_user/%{type}/claim/%{action}/summary',
                  title: '%{action_t} %{type} claim summary'
                }, claim_tracking_substitutions)
  end

  def confirmation
    track_visit({
                  url: 'external_user/%{type}/claim/%{action}/confirmation',
                  title: '%{action_t} %{type} claim confirmation'
                }, claim_tracking_substitutions)
  end

  def clone_rejected
    draft = nil
    Timeout.timeout(15) do
      draft = claim_updater.clone_rejected
    end
    LogStuff.send(:info, 'ExternalUsers::ClaimsController',
                  action: 'clone',
                  claim_id: @claim.id,
                  documents: @claim.documents.count,
                  total_size: @claim.documents.sum(:document_file_size)) do
      'Redraft succeeded'
    end

    redirect_to edit_polymorphic_path(draft), notice: 'Draft created'
  rescue StandardError => error
    LogStuff.send(:error, 'ExternalUsers::ClaimsController',
                  action: 'clone',
                  claim_id: @claim.id,
                  documents: @claim.documents.count,
                  total_size: @claim.documents.sum(:document_file_size),
                  error: error.message) do
      'Redraft failed'
    end
    redirect_to external_users_claims_url, alert: t('external_users.claims.redraft.error_html').html_safe
  end

  def destroy
    if @claim.draft?
      claim_updater.delete
      flash[:notice] = 'Claim deleted'
    elsif @claim.can_archive_pending_delete?
      claim_updater.archive
      flash[:notice] = 'Claim archived'
    else
      flash[:alert] = 'This claim cannot be deleted'
    end

    respond_with @claim, location: external_users_claims_url
  end

  def unarchive
    if @claim.archived_pending_delete?
      @claim = @claim.previous_version
      @claim.zeroise_nil_totals!
      @claim.save!
      redirect_to external_users_claims_url, notice: 'Claim unarchived'
    else
      redirect_to external_users_claim_url(@claim), alert: 'This claim cannot be unarchived'
    end
  end

  def new
    load_offences_and_case_types
    build_nested_resources
    track_visit({ url: 'external_user/%{type}/claim/new/%{step}', title: 'New %{type} claim %{step}' },
                claim_tracking_substitutions)
  end

  def edit
    unless @claim.editable?
      redirect_to external_users_claims_url, notice: 'Can only edit "draft" claims'
      return
    end

    build_nested_resources
    load_offences_and_case_types
    @disable_assessment_input = true

    @claim.touch(:last_edited_at)

    track_visit({ url: 'external_user/%{type}/claim/edit/%{step}', title: 'Edit %{type} claim %{step}' },
                claim_tracking_substitutions)
  end

  def create
    result = if submitting_to_laa?
               Claims::CreateClaim.call(@claim)
             else
               Claims::CreateDraft.call(@claim, validate: continue_claim?)
             end

    render_or_redirect(result)
  end

  def update
    result = if submitting_to_laa?
               Claims::UpdateClaim.call(@claim, params: claim_params)
             else
               Claims::UpdateDraft.call(@claim, params: claim_params, validate: continue_claim?)
             end

    render_or_redirect(result)
  end

  def disc_evidence
    send_file(
      DiscEvidenceCoversheetBuilder.new(@claim).export,
      filename: 'disc_evidence_coversheet.pdf',
      disposition: 'inline',
      type: 'application/pdf'
    )
  end

  private

  def generate_form_id
    @form_id = SecureRandom.uuid
  end

  def load_offences_and_case_types
    @offence_descriptions = Offence.unique_name
    @offences = if @claim.offence
                  Offence.where(description: @claim.offence.description)
                else
                  Offence.all
                end
    @case_types = @claim.eligible_case_types
  end

  def set_user_and_provider
    @external_user = current_user.persona
    @provider = @external_user.provider
  end

  def set_claims_context
    context = Claims::ContextMapper.new(@external_user, scheme: scheme)
    @claims_context = context.available_claims
    @available_schemes = context.available_schemes
  end

  def set_financial_summary
    @financial_summary = Claims::FinancialSummary.new(@claims_context)
  end

  def search(states = nil)
    @claims = @claims.search(params[:search], states, *search_options)
  end

  def search_options
    options = %i[case_number defendant_name]
    options << :advocate_name if @external_user.admin?
    options
  end

  def sort_column
    @claims.sortable_by?(params[:sort]) ? params[:sort] : @sort_defaults[:column]
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : @sort_defaults[:direction]
  end

  def sort_defaults(defaults = {})
    @sort_defaults = {  column:     defaults.fetch(:column, 'last_submitted_at'),
                        direction:  defaults.fetch(:direction, 'asc'),
                        pagination: defaults.fetch(:pagination, page_size) }
  end

  def sort_and_paginate(options = {})
    sort_defaults(options)
    @claims = @claims.sort(sort_column, sort_direction).page(current_page).per(@sort_defaults[:pagination])
  end

  def scheme
    %w[agfs lgfs].include?(params[:scheme]) ? params[:scheme].to_sym : :all
  end

  def set_and_authorize_claim
    @claim = Claim::BaseClaim.active.find(params[:id])
    authorize! params[:action].to_sym, @claim
  end

  def set_form_step
    return unless @claim
    return unless params[:step].present?
    @claim.form_step = params[:step]
  end

  def claim_params
    params.require(:claim).permit(
      :form_id,
      :form_step,
      :advocate_category,
      :providers_ref,
      :source,
      :external_user_id,
      :supplier_number,
      :court_id,
      :transfer_court_id,
      :transfer_case_number,
      :case_number,
      :case_type_id,
      :offence_id,
      date_attributes_for(:first_day_of_trial),
      :estimated_trial_length,
      :actual_trial_length,
      date_attributes_for(:trial_concluded_at),
      date_attributes_for(:retrial_started_at),
      :retrial_estimated_length,
      :retrial_actual_length,
      date_attributes_for(:retrial_concluded_at),
      :retrial_reduction,
      date_attributes_for(:trial_fixed_notice_at),
      date_attributes_for(:trial_fixed_at),
      date_attributes_for(:trial_cracked_at),
      date_attributes_for(:case_concluded_at),
      date_attributes_for(:effective_pcmh_date),
      date_attributes_for(:legal_aid_transfer_date),
      :trial_cracked_at_third,
      :additional_information,
      :litigator_type,
      :elected_case,
      :transfer_stage_id,
      date_attributes_for(:transfer_date),
      :case_conclusion_id,
      :disk_evidence,
      evidence_checklist_ids: [],
      defendants_attributes: [
        :id,
        :claim_id,
        :first_name,
        :last_name,
        date_attributes_for(:date_of_birth),
        :order_for_judicial_apportionment,
        :_destroy,
        representation_orders_attributes: [
          :id,
          :document,
          :maat_reference,
          date_attributes_for(:representation_order_date),
          :_destroy
        ]
      ],
      basic_fees_attributes: [
        :id,
        :claim_id,
        :fee_type_id,
        :fee_id,
        :quantity,
        :rate,
        :amount,
        :case_numbers,
        :_destroy,
        common_dates_attended_attributes
      ],
      disbursements_attributes: %i[
        id
        claim_id
        disbursement_type_id
        net_amount
        vat_amount
        _destroy
      ],
      fixed_fees_attributes: common_fees_attributes,  # agfs has_many
      fixed_fee_attributes: common_fees_attributes,   # lgfs has_one
      misc_fees_attributes: common_fees_attributes,
      graduated_fee_attributes: [
        :id,
        :claim_id,
        :fee_type_id,
        :quantity,
        :amount,
        date_attributes_for(:date)
      ],
      interim_fee_attributes: [
        :id,
        :claim_id,
        :fee_type_id,
        :quantity,
        :amount,
        date_attributes_for(:warrant_issued_date),
        date_attributes_for(:warrant_executed_date)
      ],
      transfer_fee_attributes: %i[
        id
        claim_id
        fee_type_id
        amount
        quantity
      ],
      warrant_fee_attributes: [
        :id,
        :claim_id,
        :fee_type_id,
        :amount,
        date_attributes_for(:warrant_issued_date),
        date_attributes_for(:warrant_executed_date)
      ],
      expenses_attributes: [
        :id,
        :claim_id,
        :expense_type_id,
        :location,
        :quantity,
        :amount,
        :vat_amount,
        :rate,
        :reason_id,
        :reason_text,
        :distance,
        :mileage_rate_id,
        :hours,
        date_attributes_for(:date),
        :_destroy,
        common_dates_attended_attributes
      ]
    )
  end

  def params_with_external_user_and_creator
    form_params = claim_params
    form_params[:external_user_id] ||= @external_user.id
    form_params[:creator_id] = @external_user.id
    form_params
  end

  def build_nested_resources
    %i[defendants documents].each do |association|
      build_nested_resource(@claim, association)
    end

    @claim.defendants.each { |d| build_nested_resource(d, :representation_orders) }
  end

  def build_nested_resource(object, association)
    object.send(association).build if object.send(association).none?
  end

  def submitting_to_laa?
    params.key?(:commit_submit_claim)
  end

  def continue_claim?
    params.key?(:commit_continue) || params.key?(:commit_stage_1)
  end

  def render_action_with_resources(action)
    present_errors
    build_nested_resources
    load_offences_and_case_types

    track_visit({
                  url: 'external_user/%{type}/claim/%{action}/%{step}',
                  title: '%{action_t} %{type} claim page %{step}'
                }, claim_tracking_substitutions)

    render action: action
  end

  def redirect_to_next_step
    track_visit({
                  url: 'external_user/%{type}/claim/%{action}/%{step}',
                  title: '%{action_t} %{type} claim page %{step}'
                }, claim_tracking_substitutions)

    redirect_to claim_action_path(step: @claim.next_step!)
  end

  def render_or_redirect(result)
    return render_or_redirect_error(result) unless result.success?
    render_or_redirect_success(result)
  end

  def render_or_redirect_success(result)
    if continue_claim?
      redirect_to_next_step
    elsif result.draft?
      redirect_to external_users_claims_path, notice: 'Draft claim saved'
    else
      redirect_to summary_external_users_claim_url(@claim)
    end
  end

  def render_or_redirect_error(result)
    case result.error_code
    when :already_submitted
      redirect_to external_users_claims_path, alert: 'Claim already submitted'
    when :already_saved
      redirect_to external_users_claims_path, alert: 'Claim already saved - please edit existing claim'
    else # rollback done, show errors
      render_action_with_resources(result.action)
    end
  end

  def present_errors
    @error_presenter = ErrorPresenter.new(@claim)
  end

  def initialize_json_document_importer
    @json_document_importer = JsonDocumentImporter.new
  end

  def initialize_submodel_counts
    @defendant_count                = 0
    @representation_order_count     = 0
    @basic_fee_count                = 0
    @misc_fee_count                 = 0
    @fixed_fee_count                = 0
    @expense_count                  = 0
    @expense_date_attended_count    = 0
    @disbursement_count             = 0
  end

  def claim_tracking_substitutions
    {
      type: @claim.pretty_type,
      step: @claim.current_step,
      action: @claim.edition_state,
      action_t: @claim.edition_state.titleize
    }
  end
end

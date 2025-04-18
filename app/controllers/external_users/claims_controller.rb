module ExternalUsers
  class ClaimsController < ExternalUsers::ApplicationController
    # This performs magic
    include PaginationHelpers
    include MultiparameterAttributeCleaner

    class ResourceClassNotDefined < StandardError; end

    skip_load_and_authorize_resource

    helper_method :sort_column, :sort_direction, :scheme

    respond_to :html

    prepend_before_action :clean_multiparameter_dates, only: %i[create update]
    before_action :set_user_and_provider
    before_action :set_presenters
    before_action :set_claims_context, only: %i[index archived outstanding authorised]
    before_action :set_financial_summary, only: %i[index outstanding authorised]

    before_action :set_and_authorize_claim, only: %i[show edit update unarchive clone_rejected destroy summary
                                                     confirmation show_message_controls messages]
    before_action :set_supplier_postcode, only: %i[edit update]
    before_action :set_form_step, only: %i[edit update]
    before_action :redirect_unless_editable, only: %i[edit update]
    before_action :generate_form_id, only: %i[new edit]
    before_action :initialize_submodel_counts

    include ReadMessages
    include MessageControlsDisplay

    before_action :enable_breadcrumb, only: %i[new create edit update]

    def index
      track_visit(url: 'external_user/claims', title: 'Your claims')

      @claims = @claims_context
                .dashboard_displayable_states
                .includes(:defendants, :case_type, :external_user, :assessment, :messages, :determinations)
      search if params[:search].present?
      sort_and_paginate(column: 'last_submitted_at', direction: 'asc')
    end

    def archived
      @claims = @claims_context.where(state: %w[archived_pending_delete archived_pending_review])
      search(:archived_pending_delete) if params[:search].present?
      sort_and_paginate(column: 'last_submitted_at', direction: 'desc')
    end

    def outstanding
      @claims = @financial_summary
                .outstanding_claims
                .includes(:defendants, :case_type, :external_user, :assessment, :messages, :determinations)
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
      Timeout.timeout(20) do
        draft = claim_updater.clone_rejected
      end
      log('Redraft succeeded')
      redirect_to edit_polymorphic_path(draft), notice: t('external_users.claims.redraft.success')
    rescue StandardError => e
      log('Redraft failed', level: :error, error: e)
      redirect_to external_users_claims_url, alert: t('external_users.claims.redraft.error_html').html_safe
    end

    def new
      @claim = resource_klass.new
      @claim.form_step = params[:step] || @claim.submission_stages.first
      authorize! :new, @claim
      load_offences_and_case_types
      build_nested_resources
      track_visit({ url: 'external_user/%{type}/claim/new/%{step}', title: 'New %{type} claim %{step}' },
                  claim_tracking_substitutions)
    end

    def edit
      build_nested_resources
      load_offences_and_case_types
      @disable_assessment_input = true

      @claim.touch(:last_edited_at)

      track_visit({ url: 'external_user/%{type}/claim/edit/%{step}', title: 'Edit %{type} claim %{step}' },
                  claim_tracking_substitutions)
    end

    def create
      @claim = resource_klass.new(params_with_external_user_and_creator)
      @claim.form_step ||= @claim.submission_stages.first
      authorize! :create, @claim
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

    def destroy
      message = if @claim.draft?
                  flash_message_for :delete, claim_updater.delete
                elsif @claim.can_archive_pending_delete? || @claim.can_archive_pending_review?
                  flash_message_for :archive, claim_updater.archive
                else
                  { alert: 'This claim cannot be deleted' }
                end
      flash[message.keys.first.to_sym] = message.values.first
      respond_with @claim, location: external_users_claims_url
    end

    def unarchive
      claim_url = external_users_claim_url(@claim)
      return redirect_to claim_url, alert: t('.not_archived') unless unarchive_allowed?
      @claim = @claim.paper_trail.previous_version
      @claim.zeroise_nil_totals!
      @claim.save!(validate: false)
      redirect_to external_users_claims_url, notice: t('.unarchived')
    rescue StandardError
      redirect_to claim_url, alert: t('.unarchivable')
    end

    class << self
      def resource_klass(klass)
        @resource_klass ||= klass
      end

      def defined_resource_class
        @resource_klass || raise(ResourceClassNotDefined)
      end
    end

    protected

    def resource_klass
      self.class.defined_resource_class
    end

    private

    def log(message, error: nil, level: :info)
      log_data = {
        action: 'clone', claim_id: @claim.id, documents: @claim.documents.count,
        total_size: helpers.number_to_human_size(@claim.documents.sum { |doc| doc.document.byte_size })
      }
      if error
        log_data[:error] = "#{error.class}: #{error.message}"
        log_data[:backtrace] = error.backtrace
      end
      LogStuff.send(level, 'ExternalUsers::ClaimsController', **log_data) { message }
    end

    def generate_form_id
      @form_id = SecureRandom.uuid
    end

    def load_offences_and_case_types
      @offences = Claims::FetchEligibleOffences.for(@claim)
      @offence_descriptions = Offence.unique_name
      @case_types = @claim.respond_to?(:eligible_case_types) ? @claim&.eligible_case_types : []
    end

    def set_user_and_provider
      @external_user = current_user.persona
      @provider = @external_user.provider
    end

    def set_presenters
      @defendant_presenter = ExternalUsers::DefendantPresenter
    end

    def set_claims_context
      context = Claims::ContextMapper.new(@external_user, scheme:)
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
      @sort_defaults = {  column: defaults.fetch(:column, 'last_submitted_at'),
                          direction: defaults.fetch(:direction, 'asc'),
                          pagination: defaults.fetch(:pagination, page_size) }
    end

    def sort_and_paginate(options = {})
      sort_defaults(options)
      @pagy, @claims = pagy(@claims.sort_using(sort_column, sort_direction), page: current_page,
                                                                             limit: @sort_defaults[:pagination])
    end

    def scheme
      %w[agfs lgfs].include?(params[:scheme]) ? params[:scheme].to_sym : :all
    end

    def set_and_authorize_claim
      @claim = Claim::BaseClaim.active.find(params[:id])
      authorize! params[:action].to_sym, @claim
    end

    def set_supplier_postcode
      @supplier_postcode = SupplierNumber.find_by(supplier_number: @claim&.supplier_number)&.postcode
    end

    def set_form_step
      return unless @claim
      @claim.form_step = params[:step] ||
                         (params.key?(:claim) && claim_params[:form_step]) ||
                         @claim.submission_stages.first
    end

    # rubocop:disable Metrics/MethodLength
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
        :case_transferred_from_another_court,
        :transfer_court_id,
        :transfer_case_number,
        :case_number,
        :case_type_id,
        :case_stage_id,
        :offence_id,
        :travel_expense_additional_information,
        :first_day_of_trial,
        :estimated_trial_length,
        :actual_trial_length,
        :trial_concluded_at,
        :retrial_started_at,
        :retrial_estimated_length,
        :retrial_actual_length,
        :main_hearing_date,
        :retrial_concluded_at,
        :retrial_reduction,
        :trial_fixed_notice_at,
        :trial_fixed_at,
        :trial_cracked_at,
        :case_concluded_at,
        :effective_pcmh_date,
        :legal_aid_transfer_date,
        :trial_cracked_at_third,
        :additional_information,
        :litigator_type,
        :elected_case,
        :transfer_stage_id,
        :transfer_date,
        :case_conclusion_id,
        :disk_evidence,
        :prosecution_evidence,
        evidence_checklist_ids: [],
        defendants_attributes: [
          :id,
          :claim_id,
          :first_name,
          :last_name,
          :date_of_birth,
          :order_for_judicial_apportionment,
          :_destroy,
          { representation_orders_attributes: %i[
            id
            document
            maat_reference
            representation_order_date
            _destroy
          ] }
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
          :price_calculated,
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
        fixed_fees_attributes: common_fees_attributes, # agfs has_many
        fixed_fee_attributes: common_fees_attributes, # lgfs has_one
        misc_fees_attributes: common_fees_attributes,
        graduated_fee_attributes: %i[
          id
          claim_id
          fee_type_id
          quantity
          amount
          price_calculated
          date
        ],
        interim_fee_attributes: %i[
          id
          claim_id
          fee_type_id
          quantity
          amount
          price_calculated
          warrant_issued_date
          warrant_executed_date
        ],
        transfer_fee_attributes: %i[
          id
          claim_id
          fee_type_id
          amount
          price_calculated
          quantity
        ],
        warrant_fee_attributes: %i[
          id
          claim_id
          fee_type_id
          amount
          price_calculated
          warrant_issued_date
          warrant_executed_date
        ],
        hardship_fee_attributes: %i[
          id
          claim_id
          fee_type_id
          amount
          price_calculated
          quantity
        ],
        expenses_attributes: [
          :id,
          :claim_id,
          :expense_type_id,
          :location,
          :location_type,
          :quantity,
          :amount,
          :vat_amount,
          :rate,
          :reason_id,
          :reason_text,
          :distance,
          :calculated_distance,
          :mileage_rate_id,
          :hours,
          :date,
          :_destroy,
          common_dates_attended_attributes
        ],
        interim_claim_info_attributes: %i[
          warrant_fee_paid
          warrant_issued_date
          warrant_executed_date
        ]
      )
    end
    # rubocop:enable Metrics/MethodLength

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
      params.key?(:commit_continue)
    end

    def render_action_with_resources(action)
      present_errors
      build_nested_resources
      load_offences_and_case_types

      track_visit({
                    url: 'external_user/%{type}/claim/%{action}/%{step}',
                    title: '%{action_t} %{type} claim page %{step}'
                  }, claim_tracking_substitutions)

      render action:
    end

    def redirect_to_next_step
      track_visit({
                    url: 'external_user/%{type}/claim/%{action}/%{step}',
                    title: '%{action_t} %{type} claim page %{step}'
                  }, claim_tracking_substitutions)

      redirect_to edit_polymorphic_path(@claim, step: @claim.next_step)
    end

    def render_or_redirect(result)
      return render_or_redirect_error(result) unless result.success?
      render_or_redirect_success(result)
    end

    def render_or_redirect_success(result)
      if continue_claim?
        redirect_to_next_step
      elsif result.draft?
        redirect_to external_users_claims_path, notice: t('external_users.claims.update.success')
      else
        redirect_to summary_external_users_claim_url(@claim)
      end
    end

    def render_or_redirect_error(result)
      case result.error_code
      when :already_submitted
        redirect_to external_users_claims_path, alert: t('errors.already_submitted', scope: default_scope)
      when :already_saved
        redirect_to external_users_claims_path, alert: t('errors.already_saved', scope: default_scope)
      else # rollback done, show errors
        render_action_with_resources(result.action)
      end
    end

    def present_errors
      @error_presenter = ErrorMessage::Presenter.new(@claim)
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

    def redirect_unless_editable
      return if @claim.current_step_editable?
      error_code = @claim.editable? ? :dependencies_missing : :not_editable
      options = redirect_options_for(error_code)
      redirect_to options[:url], alert: options[:message]
    end

    def redirect_options_for(error_code)
      {
        not_editable: {
          url: external_users_claims_url,
          message: t('errors.not_editable', scope: default_scope)
        },
        dependencies_missing: {
          url: summary_external_users_claim_path(@claim),
          message: t('errors.dependencies_missing', scope: default_scope)
        }
      }[error_code&.to_sym]
    end

    def default_scope
      %i[external_users claims]
    end

    def flash_message_for(event, status)
      status ? { notice: "Claim #{event}d" } : { alert: "Claim could not be #{event}d" }
    end

    def unarchive_allowed?
      @claim.archived_pending_delete? || @claim.archived_pending_review?
    end
  end
end

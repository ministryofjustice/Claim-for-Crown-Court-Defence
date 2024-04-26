module Claim
  class BaseClaimAbstractClassError < RuntimeError
    def initialize(message = 'Claim::BaseClaim is an abstract class and cannot be instantiated')
      super
    end
  end

  class BaseClaim < ApplicationRecord
    include SoftlyDeletable

    self.table_name = 'claims'

    auto_strip_attributes :case_number, :cms_number, :supplier_number, squish: true, nullify: true

    serialize :evidence_checklist_ids, type: Array

    attr_reader :form_step
    alias current_step form_step

    attr_accessor :disable_for_state_transition, :reject_reason_text, :refuse_reason_text, :state_reason
    attribute :case_transferred_from_another_court, :boolean

    include ::Claims::StateMachine
    extend ::Claims::Search
    extend ::Claims::Sort
    include ::Claims::Calculations
    include ::Claims::Cloner
    include ::Claims::AllocationFilters

    include NumberCommaParser
    numeric_attributes :fees_total, :expenses_total, :disbursements_total, :total, :vat_amount

    belongs_to :court
    belongs_to :transfer_court, class_name: 'Court'
    belongs_to :offence
    belongs_to :external_user
    belongs_to :creator, class_name: 'ExternalUser'
    belongs_to :case_type
    belongs_to :case_stage

    delegate :provider_id, :provider, to: :creator
    delegate :requires_trial_dates?, :requires_retrial_dates?, to: :case_type, allow_nil: true
    delegate :agfs_reform?, :agfs_scheme_12?, :agfs_scheme_13?, :agfs_scheme_14?,
             :agfs_scheme_15?, :agfs_scheme_16?, to: :fee_scheme, allow_nil: true

    has_many :case_worker_claims, foreign_key: :claim_id, dependent: :destroy
    has_many :case_workers, through: :case_worker_claims
    has_many :fees, foreign_key: :claim_id, class_name: 'Fee::BaseFee', dependent: :destroy, inverse_of: :claim
    has_many :fee_types, through: :fees, class_name: 'Fee::BaseFeeType'
    has_many :expenses, foreign_key: :claim_id, dependent: :destroy, inverse_of: :claim do
      def with_vat
        select(&:vat_present?)
      end

      def without_vat
        select(&:vat_absent?)
      end
    end

    has_many :disbursements, foreign_key: :claim_id, dependent: :destroy, inverse_of: :claim do
      def with_vat
        select(&:vat_present?)
      end

      def without_vat
        select(&:vat_absent?)
      end
    end
    has_many :defendants, foreign_key: :claim_id, dependent: :destroy, inverse_of: :claim
    has_many :documents, -> { where verified: true }, foreign_key: :claim_id, dependent: :destroy, inverse_of: :claim
    has_many :messages, foreign_key: :claim_id, dependent: :destroy, inverse_of: :claim

    has_many :claim_state_transitions, -> { order(created_at: :desc, id: :desc) },
             foreign_key: :claim_id,
             dependent: :destroy,
             inverse_of: :claim

    has_many :misc_fees, foreign_key: :claim_id, class_name: 'Fee::MiscFee', dependent: :destroy, inverse_of: :claim

    has_many :determinations, foreign_key: :claim_id, dependent: :destroy
    has_one :assessment, foreign_key: :claim_id

    def assessment
      super || build_assessment
    end

    has_many :redeterminations, foreign_key: :claim_id
    has_many :injection_attempts, foreign_key: :claim_id, dependent: :destroy

    has_one  :certification, foreign_key: :claim_id, dependent: :destroy

    has_paper_trail on: [:update], only: [:state]

    # external user relevant scopes
    scope :outstanding, -> { where(state: %w[submitted allocated]) }
    scope :any_authorised, -> { where(state: %w[part_authorised authorised]) }

    scope :dashboard_displayable_states, -> { where(state: Claims::StateMachine.dashboard_displayable_states) }

    scope :total_greater_than_or_equal_to, ->(value) { where(arel_table[:total].gteq(value)) }
    scope :total_lower_than, ->(value) { where(arel_table[:total].lt(value)) }

    scope :cloned, -> { where.not(clone_source_id: nil) }

    scope :agfs, -> { where(type: agfs_claim_types.map(&:to_s)) }
    scope :lgfs, -> { where(type: lgfs_claim_types.map(&:to_s)) }

    accepts_nested_attributes_for :misc_fees,         reject_if: all_blank_or_zero, allow_destroy: true
    accepts_nested_attributes_for :expenses,          reject_if: all_blank_or_zero, allow_destroy: true
    accepts_nested_attributes_for :disbursements,     reject_if: all_blank_or_zero, allow_destroy: true
    accepts_nested_attributes_for :defendants,        reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :assessment
    accepts_nested_attributes_for :redeterminations, reject_if: :all_blank

    before_validation do
      errors.clear
      cleaner&.call
      reset_transfer_court_details unless case_transferred_from_another_court
      documents.each { |d| d.external_user_id = external_user_id }
    end

    after_initialize :ensure_not_abstract_class,
                     :default_values,
                     :set_force_validation_to_false

    before_create do
      build_associations
    end

    before_save do
      self.value_band_id = Claims::ValueBands.band_id_for_claim(self)
    end

    after_save :find_and_associate_documents, :update_vat

    def ensure_not_abstract_class
      raise BaseClaimAbstractClassError if instance_of?(BaseClaim)
    end

    def form_step=(step)
      @form_step = step&.to_sym
    end

    def step_in_steps_range?(step)
      submission_current_flow.map(&:to_sym).include?(step)
    end

    def step_back?
      previous_step.present?
    end

    def next_step?
      next_step.present?
    end

    def invalid_steps
      @invalid_steps ||= Claims::ValidateAllSteps.call(self)
    end

    def accessible_step?(step)
      full_submission_flow.include?(step)
    end

    def editable_step?(step)
      Claims::CheckStepEditability.call(self, step).valid?
    end

    def current_step_editable?
      editable_step?(current_step)
    end

    def missing_dependencies_for(step)
      Claims::CheckStepEditability.call(self, step).invalid_dependencies
    end

    def misc_fees_changed?
      misc_fees.any?(&:changed?)
    end

    def expenses_changed?
      expenses.any?(&:changed?)
    end

    # Override the corresponding method in the subclass
    def agfs?
      false
    end

    def lgfs?
      false
    end

    def interim?
      false
    end

    def hardship?
      false
    end

    def supplementary?
      false
    end

    def transfer?
      false
    end

    def final?
      false
    end

    def requires_cracked_dates?
      false
    end

    def requires_case_concluded_date?
      false
    end

    def case_transferred_from_another_court=(value)
      attribute_will_change!('case_transferred_from_another_court') if @case_transferred_from_another_court != value
      @case_transferred_from_another_court = value.to_s.casecmp('true').zero?
    end

    def case_transferred_from_another_court
      return @case_transferred_from_another_court if case_transferred_from_another_court_changed?
      unless @case_transferred_from_another_court.nil? || transfer_court_details_changed?
        return @case_transferred_from_another_court
      end
      @case_transferred_from_another_court ||= default_case_transferred_from_another_court
    end

    def case_transferred_from_another_court_changed?
      will_save_change_to_case_transferred_from_another_court?
    end

    def self.claim_types
      agfs_claim_types | lgfs_claim_types
    end

    def self.agfs_claim_types
      [Claim::AdvocateClaim,
       Claim::AdvocateInterimClaim,
       Claim::AdvocateSupplementaryClaim,
       Claim::AdvocateHardshipClaim]
    end

    def self.lgfs_claim_types
      [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim, Claim::LitigatorHardshipClaim]
    end

    def self.agfs?
      agfs_claim_types.include?(self)
    end

    def self.lgfs?
      lgfs_claim_types.include?(self)
    end

    def self.filter_by(filter)
      case filter.to_s
      when 'redetermination', 'awaiting_written_reasons', 'all'
        send(filter)
      when 'fixed_fee', 'cracked', 'trial', 'guilty_plea', 'graduated_fees',
           'interim_fees', 'warrants', 'interim_disbursements', 'risk_based_bills'
        where.not(state: %w[redetermination awaiting_written_reasons]).send(filter)
      else
        raise format('unknown filter: %{filter}', filter:)
      end
    end

    def self.value_band(value_band_id)
      if value_band_id == '0' # this means no selection on value bands
        where.not(value_band_id: nil)
      else
        where(value_band_id:)
      end
    end

    def pretty_type
      type.demodulize.sub('Claim', '').downcase
    end

    def edition_state
      last_edited_at? ? 'edit' : 'new'
    end

    def set_force_validation_to_false
      @force_validation = false
    end

    attr_writer :force_validation

    def force_validation?
      @force_validation
    end

    def redetermination_since_allocation?
      if last_state_transition.from == 'redetermination'
        last_state_transition_later_than_redetermination?(last_state_transition)
      else
        false
      end
    end

    # Do not use `has_many :representation_orders, through: :defendants`
    # The relationship is not properly handled on partial claim validation
    #
    def representation_orders
      defendants.reduce([]) { |a, e| a.concat(e.representation_orders) }
    end

    def earliest_representation_order
      return if defendants.empty?

      defendants.filter_map(&:earliest_representation_order).min_by(&:representation_order_date)
    end

    def earliest_representation_order_date
      earliest_representation_order.try(:representation_order_date)
    end

    def evidence_doc_types
      DocType.find_by_ids(evidence_checklist_ids)
    end

    # responds to methods like claim.external_user_dashboard_submitted? which correspond to the
    # constant EXTERNAL_USER_DASHBOARD_REJECTED_STATES in Claims::StateMachine
    def method_missing(method, *args)
      if Claims::StateMachine.can_be_in_state?(method)
        Claims::StateMachine.in_state?(method, self)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      Claims::StateMachine.can_be_in_state?(method) || super
    end

    def allocated_to_case_worker?(case_worker)
      case_workers.include?(case_worker)
    end

    def authorised_state?
      Claims::StateMachine::AUTHORISED_STATES.include?(state)
    end

    def editable?
      draft?
    end

    def archivable?
      VALID_STATES_FOR_ARCHIVAL.include?(state)
    end

    def rejectable?
      allocated? && !opened_for_redetermination?
    end

    def redeterminable?
      VALID_STATES_FOR_REDETERMINATION.include?(state) && !(lgfs? && interim?)
    end

    def applicable_for_written_reasons?
      claim_state_transitions.any? { |x| x.to == 'redetermination' } && !hardship?
    end

    def perform_validation?
      force_validation? || validation_required?
    end

    # validation required when
    # being created from api (as draft)
    # or is in state of archived_pending_delete or draft (not from api)
    # or is in a state deleted (old statement????)
    # or is transitioning via certain events
    #
    def validation_required?
      return true if from_api?
      return false if draft? || archived_pending_delete? || disabled_for_transition?
      true
    end

    def step_validation_required?(step)
      from_api? || form_step.nil? || form_step == step
    end

    def disabled_for_transition?
      disable_for_state_transition.present?
    end

    def submission_stages
      @submission_stages ||= StageCollection.new(self.class::SUBMISSION_STAGES, self)
    end

    def submission_current_flow
      return submission_stages if from_api?
      submission_stages.path_until(form_step)
    end

    def full_submission_flow
      submission_stages.path_until(submission_stages.last&.to_sym)
    end

    def previous_step
      return unless form_step
      submission_stages.previous_stage(form_step)&.to_sym
    end

    def next_step
      return unless form_step
      submission_stages.next_stage(form_step)&.to_sym
    end

    def next_step!
      return unless form_step
      self.form_step = next_step
    end

    def from_api?
      source == 'api'
    end

    def api_web_edited?
      source == 'api_web_edited'
    end

    def from_web?
      source == 'web'
    end

    def api_draft?
      draft? && from_api?
    end

    def vat_date
      (original_submission_date || Time.zone.today).to_date
    end

    def pretty_vat_rate
      VatRate.pretty_rate(vat_date)
    end

    def enable_assessment_input?
      assessment.blank? && state == 'allocated'
    end

    def enable_redetermination_input?
      state == 'allocated' && (opened_for_redetermination? || written_reasons_outstanding?)
    end

    def enable_determination_input?
      enable_assessment_input? || enable_redetermination_input?
    end

    def opened_for_redetermination?
      return true if redetermination?

      transition = filtered_last_state_transition
      transition&.to == 'redetermination'
    end

    def written_reasons_outstanding?
      return true if awaiting_written_reasons?

      transition = filtered_last_state_transition
      transition&.to == 'awaiting_written_reasons'
    end

    def amount_assessed
      determinations.last.total_including_vat
    end

    def total_including_vat
      total + vat_amount
    end

    def vat_registered?
      if provider_delegator.nil?
        LogStuff.send(:error, 'vat_registration',
                      action: 'vat_registration',
                      provider_id: provider&.id,
                      creator_id: creator&.id,
                      claim_id: id) do
          "calculating VAT for #{id}"
        end
      end
      provider_delegator&.vat_registered?
    end

    def trial_length
      if requires_retrial_dates?
        retrial_actual_length
      elsif requires_trial_dates?
        actual_trial_length
      end
    end

    def allows_graduated_fees?
      case_type.try(:graduated_fee_type).present?
    end

    def allows_fixed_fees?
      case_type&.is_fixed_fee?
    end
    alias fixed_fee_case? allows_fixed_fees?

    def update_claim_document_owners
      documents.each { |d| d.update_column(:creator_id, creator_id) }
    end

    # This will ensure proper route paths are generated
    # when using helpers like: edit_polymorphic_path(claim)
    def self.route_key_name(name)
      model_name.class_eval %(
        def singular_route_key; '#{name}'; end
        def route_key; '#{name.pluralize}'; end
      ), __FILE__, __LINE__ - 3
    end

    def self.fee_associations
      reflect_on_all_associations.select { |assoc| assoc.name =~ /^\S+_fees?$/ }.map(&:name)
    end

    def disk_evidence_reference
      return unless case_number && id
      "#{case_number}/#{id}"
    end

    def requires_case_type?
      true
    end

    def expenses_with_vat_net
      expenses.with_vat.sum(&:amount)
    end

    def expenses_with_vat_gross
      expenses_with_vat_net + expenses_vat
    end

    def expenses_without_vat_net
      expenses.without_vat.sum(&:amount)
    end

    def expenses_without_vat_gross
      expenses_without_vat_net
    end

    def disbursements_with_vat_net
      disbursements.with_vat.sum(&:net_amount)
    end

    def disbursements_with_vat_gross
      disbursements_with_vat_net + disbursements_vat
    end

    def disbursements_without_vat_net
      disbursements.without_vat.sum(&:net_amount)
    end

    def disbursements_without_vat_gross
      disbursements_without_vat_net
    end

    def zeroise_nil_totals!
      self.fees_vat = 0.0 if fees_vat.nil?
      self.expenses_vat = 0.0 if expenses_vat.nil?
      self.disbursements_vat = 0.0 if disbursements_vat.nil?
    end

    def fee_scheme
      return offence&.fee_schemes&.find_by(name: agfs? ? 'AGFS' : 'LGFS') if earliest_representation_order_date.nil?

      fee_scheme_factory.call(
        representation_order_date: earliest_representation_order_date,
        main_hearing_date:
      )
    end

    def eligible_document_types
      Claims::FetchEligibleDocumentTypes.for(self)
    end

    def eligible_misc_fee_types
      Claims::FetchEligibleMiscFeeTypes.new(self).call
    end

    def discontinuance?
      case_type&.fee_type_code.eql?('GRDIS')
    end

    def unread_messages_for(user)
      messages.joins(:user_message_statuses).where(user_message_statuses: { read: false, user: })
    end

    private

    # called from state_machine before_transition on submit - override in subclass
    def set_allocation_type; end

    def reset_transfer_court_details
      self.transfer_court = nil
      self.transfer_case_number = nil
    end

    def cleaner
      Cleaners::NullClaimCleaner.new(self)
    end

    def find_and_associate_documents
      return if form_id.nil?

      Document.where(form_id:).update_all(claim_id: id, external_user_id:)
    end

    def last_state_transition_later_than_redetermination?(last_state_transition)
      last_redetermination.nil? ? true : last_redetermination.created_at < last_state_transition.created_at
    end

    def build_associations
      assessment || true
    end

    def default_values
      self.source ||= 'web'
    end

    def default_case_transferred_from_another_court
      transfer_court.present? || transfer_case_number.present?
    end

    def transfer_court_details_changed?
      will_save_change_to_transfer_court_id? || will_save_change_to_transfer_case_number?
    end
  end
end

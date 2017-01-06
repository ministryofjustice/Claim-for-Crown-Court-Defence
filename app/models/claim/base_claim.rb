# == Schema Information
#
# Table name: claims
#
#  id                       :integer          not null, primary key
#  additional_information   :text
#  apply_vat                :boolean
#  state                    :string
#  last_submitted_at        :datetime
#  case_number              :string
#  advocate_category        :string
#  first_day_of_trial       :date
#  estimated_trial_length   :integer          default(0)
#  actual_trial_length      :integer          default(0)
#  fees_total               :decimal(, )      default(0.0)
#  expenses_total           :decimal(, )      default(0.0)
#  total                    :decimal(, )      default(0.0)
#  external_user_id         :integer
#  court_id                 :integer
#  offence_id               :integer
#  created_at               :datetime
#  updated_at               :datetime
#  valid_until              :datetime
#  cms_number               :string
#  authorised_at            :datetime
#  creator_id               :integer
#  evidence_notes           :text
#  evidence_checklist_ids   :string
#  trial_concluded_at       :date
#  trial_fixed_notice_at    :date
#  trial_fixed_at           :date
#  trial_cracked_at         :date
#  trial_cracked_at_third   :string
#  source                   :string
#  vat_amount               :decimal(, )      default(0.0)
#  uuid                     :uuid
#  case_type_id             :integer
#  form_id                  :string
#  original_submission_date :datetime
#  retrial_started_at       :date
#  retrial_estimated_length :integer          default(0)
#  retrial_actual_length    :integer          default(0)
#  retrial_concluded_at     :date
#  type                     :string
#  disbursements_total      :decimal(, )      default(0.0)
#  case_concluded_at        :date
#  transfer_court_id        :integer
#  supplier_number          :string
#  effective_pcmh_date      :date
#  legal_aid_transfer_date  :date
#  allocation_type          :string
#  transfer_case_number     :string
#  clone_source_id          :integer
#  last_edited_at           :datetime
#  deleted_at               :datetime
#  providers_ref            :string
#  disk_evidence            :boolean          default(FALSE)
#  fees_vat                 :decimal(, )      default(0.0)
#  expenses_vat             :decimal(, )      default(0.0)
#  disbursements_vat        :decimal(, )      default(0.0)
#

module Claim

  class BaseClaimAbstractClassError < RuntimeError
    def initialize(message = 'Claim::BaseClaim is an abstract class and cannot be instantiated')
      super(message)
    end
  end

  class BaseClaim < ActiveRecord::Base
    include SoftlyDeletable

    self.table_name = 'claims'

    auto_strip_attributes :case_number, :cms_number, :supplier_number, squish: true, nullify: true

    serialize :evidence_checklist_ids, Array

    attr_accessor :form_step

    include ::Claims::StateMachine
    extend ::Claims::Search
    extend ::Claims::Sort
    include ::Claims::Calculations
    include ::Claims::UserMessages
    include ::Claims::Cloner
    include ::Claims::AllocationFilters

    include NumberCommaParser
    numeric_attributes :fees_total, :expenses_total, :disbursements_total, :total, :vat_amount

    belongs_to :court
    belongs_to :transfer_court, foreign_key: 'transfer_court_id', class_name: 'Court'
    belongs_to :offence
    belongs_to :external_user
    belongs_to :creator, foreign_key: 'creator_id', class_name: 'ExternalUser'
    belongs_to :case_type

    delegate :provider_id, :provider, to: :creator
    delegate :requires_trial_dates?, :requires_retrial_dates?, to: :case_type

    has_many :case_worker_claims,       foreign_key: :claim_id, dependent: :destroy
    has_many :case_workers,             through: :case_worker_claims
    has_many :fees,                     foreign_key: :claim_id, class_name: 'Fee::BaseFee', dependent: :destroy,          inverse_of: :claim
    has_many :fee_types,                through: :fees, class_name: Fee::BaseFeeType
    has_many :expenses,                 foreign_key: :claim_id, dependent: :destroy,          inverse_of: :claim do
      def with_vat
        self.select{ |expense| expense.vat_present? }
      end

      def without_vat
        self.select{ |expense| expense.vat_absent? }
      end
    end


    has_many :disbursements,            foreign_key: :claim_id, dependent: :destroy,          inverse_of: :claim do
      def with_vat
        self.select{ |d| d.vat_present? }
      end

      def without_vat
        self.select{ |d| d.vat_absent? }
      end
    end
    has_many :defendants,               foreign_key: :claim_id, dependent: :destroy,          inverse_of: :claim
    has_many :documents, -> { where verified: true }, foreign_key: :claim_id, dependent: :destroy, inverse_of: :claim
    has_many :messages,                 foreign_key: :claim_id, dependent: :destroy,          inverse_of: :claim

    has_many :claim_state_transitions, -> { order(created_at: :desc) }, foreign_key: :claim_id, dependent: :destroy, inverse_of: :claim

    has_many :misc_fees, foreign_key: :claim_id, class_name: 'Fee::MiscFee', dependent: :destroy, inverse_of: :claim

    has_many :determinations, foreign_key: :claim_id, dependent: :destroy
    has_one  :assessment, foreign_key: :claim_id
    has_many :redeterminations, foreign_key: :claim_id

    has_one  :certification, foreign_key: :claim_id, dependent: :destroy
    has_one  :exported_claim, foreign_key: :claim_id, dependent: :destroy

    has_paper_trail on: [:update], only: [:state]

    # external user relevant scopes
    scope :outstanding, -> { where(state: %w( submitted allocated )) }
    scope :any_authorised,  -> { where(state: %w( part_authorised authorised )) }

    scope :dashboard_displayable_states, -> { where(state: Claims::StateMachine.dashboard_displayable_states) }

    scope :total_greater_than_or_equal_to, -> (value) { where { total >= value } }
    scope :total_lower_than, -> (value) { where { total < value } }

    scope :cloned, -> { where.not(clone_source_id: nil) }

    scope :agfs, -> { where(type: 'Claim::AdvocateClaim') }
    scope :lgfs, -> { where.not(type: 'Claim::AdvocateClaim') }

    accepts_nested_attributes_for :misc_fees,         reject_if: all_blank_or_zero, allow_destroy: true
    accepts_nested_attributes_for :expenses,          reject_if: all_blank_or_zero, allow_destroy: true
    accepts_nested_attributes_for :disbursements,     reject_if: all_blank_or_zero, allow_destroy: true
    accepts_nested_attributes_for :defendants,        reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :assessment
    accepts_nested_attributes_for :redeterminations,  reject_if: :all_blank

    acts_as_gov_uk_date :first_day_of_trial,
                        :trial_concluded_at,
                        :trial_fixed_notice_at,
                        :trial_fixed_at,
                        :trial_cracked_at,
                        :retrial_started_at,
                        :retrial_concluded_at,
                        :case_concluded_at,
                        :effective_pcmh_date,
                        :legal_aid_transfer_date, validate_if: :perform_validation?, error_clash_behaviour: :override_with_gov_uk_date_field_error

    before_validation do
      errors.clear
      destroy_all_invalid_fee_types
      documents.each { |d| d.external_user_id = self.external_user_id }
    end

    after_initialize :ensure_not_abstract_class,
                     :default_values,
                     :set_force_validation_to_false

    before_create do
      self.build_assessment if self.assessment.nil?
    end

    before_save do
      self.value_band_id = Claims::ValueBands.band_id_for_claim(self)
    end

    after_save :find_and_associate_documents, :update_vat

    def ensure_not_abstract_class
      raise BaseClaimAbstractClassError if self.class == BaseClaim
    end

    # Override the corresponding method in the subclass
    def agfs?; false; end
    def lgfs?; false; end
    def interim?; false; end
    def transfer?; false; end
    def final?; false; end
    def requires_cracked_dates?; false; end
    def requires_case_concluded_date?; false; end

    def self.agfs?
      [Claim::AdvocateClaim].include?(self)
    end

    def self.lgfs?
      [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim].include?(self)
    end

    def self.filter(filter)
      case filter.to_s
      when 'redetermination', 'awaiting_written_reasons', 'all'
        send(filter)
      when 'fixed_fee', 'cracked', 'trial', 'guilty_plea', 'graduated_fees', 'interim_fees', 'warrants', 'interim_disbursements', 'risk_based_bills'
        where.not(state: %w(redetermination awaiting_written_reasons)).send(filter)
      else
        raise 'unknown filter: %s' % filter
      end
    end


    def self.value_band(value_band_id)
      if value_band_id =='0'   # this means no selection on value bands
        where.not(value_band_id: nil)
      else
        where(value_band_id: value_band_id)
      end
    end

    def set_amount_assessed(options)
      self.build_assessment if self.assessment.nil?
      self.assessment.update_values(options[:fees], options[:expenses], options[:disbursements])
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

    def force_validation=(bool)
      @force_validation = bool
    end

    def force_validation?
      @force_validation
    end

    # if allocated, and the last state was redetermination and happened since the last redetermination record was created
    def requested_redetermination?
      self.allocated? ? redetermination_since_allocation? : false
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
      defendants.reduce([]) { |col, d| col.concat(d.representation_orders) }
    end

    def earliest_representation_order
      representation_orders.sort do |a, b|
        (a.representation_order_date || 100.years.from_now) <=> (b.representation_order_date || 100.years.from_now)
      end.first
    end

    def earliest_representation_order_date
      earliest_representation_order.try(:representation_order_date)
    end

    def evidence_doc_types
      DocType.find_by_ids(evidence_checklist_ids)
    end

    # responds to methods like claim.external_user_dashboard_submitted? which correspond to the constant EXTERNAL_USER_DASHBOARD_REJECTED_STATES in Claims::StateMachine
    def method_missing(method, *args)
      if Claims::StateMachine.has_state?(method)
        Claims::StateMachine.is_in_state?(method, self)
      else
        super
      end
    end

    def is_allocated_to_case_worker?(cw)
      self.case_workers.include?(cw)
    end

    def has_authorised_state?
      Claims::StateMachine::AUTHORISED_STATES.include?(self.state)
    end

    def editable?
      draft?
    end

    def archivable?
      VALID_STATES_FOR_ARCHIVAL.include?(self.state)
    end

    def rejectable?
      allocated? && !opened_for_redetermination?
    end

    def redeterminable?
      VALID_STATES_FOR_REDETERMINATION.include?(self.state) && !interim?
    end

    def perform_validation?
      self.force_validation? || self.validation_required?
    end

    # we must validate unless it is being created as draft from any source except API or is in state of archive_pending_delete or deleted
    def validation_required?
      from_api? || !(draft? || archived_pending_delete?)
    end

    def step?(num)
      current_step == num
    end

    def next_step!
      self.form_step = current_step + 1
    end

    def current_step
      self.form_step.to_i
    end

    def current_step_index
      current_step - 1
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

    def from_json_import?
      source == 'json_import'
    end

    def json_import_web_edited?
      source == 'json_import_web_edited'
    end

    def api_draft?
      draft? && from_api?
    end

    def vat_date
      (self.original_submission_date || Date.today).to_date
    end

    def pretty_vat_rate
      VatRate.pretty_rate(self.vat_date)
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
      return true if self.redetermination?

      transition = filtered_last_state_transition
      transition && transition.to == 'redetermination'
    end

    def written_reasons_outstanding?
      return true if self.awaiting_written_reasons?

      transition = filtered_last_state_transition
      transition && transition.to == 'awaiting_written_reasons'
    end

    def amount_assessed
      determinations.last.total_including_vat
    end

    def total_including_vat
      self.total + self.vat_amount
    end

    def vat_registered?
      provider_delegator.vat_registered?
    end

    def allows_graduated_fees?
      case_type.try(:graduated_fee_type).present?
    end

    def allows_fixed_fees?
      case_type.is_fixed_fee?
    end

    def update_claim_document_owners
      documents.each { |d| d.update_column(:creator_id, self.creator_id) }
    end

    # This will ensure proper route paths are generated
    # when using helpers like: edit_polymorphic_path(claim)
    def self.set_singular_route_key(name)
      model_name.class_eval %Q{
        def singular_route_key; '#{name}'; end
        def route_key; '#{name.pluralize}'; end
      }
    end

    def self.fee_associations
      reflect_on_all_associations.select{ |assoc| assoc.name =~ /^\S+_fees?$/ }.map(&:name)
    end

    def disk_evidence_reference
      "#{self.case_number}/#{self.id}"
    end

    def requires_case_type?
      true
    end

    def expenses_with_vat_net
      self.expenses.with_vat.sum(&:amount)
    end

    def expenses_with_vat_gross
      expenses_with_vat_net + self.expenses_vat
    end

    def expenses_without_vat_net
      self.expenses.without_vat.sum(&:amount)
    end

    def expenses_without_vat_gross
      expenses_without_vat_net
    end


    def disbursements_with_vat_net
      self.disbursements.with_vat.sum(&:net_amount)
    end

    def disbursements_with_vat_gross
      disbursements_with_vat_net + self.disbursements_vat
    end

    def disbursements_without_vat_net
      self.disbursements.without_vat.sum(&:net_amount)
    end

    def disbursements_without_vat_gross
      disbursements_without_vat_net
    end

    def fee_scheme_version
      FeeSchemeManager.version(self)
    end

    def zeroise_nil_totals!
      self.fees_vat = 0.0 if self.fees_vat.nil?
      self.expenses_vat = 0.0 if self.expenses_vat.nil?
      self.disbursements_vat = 0.0 if self.disbursements_vat.nil?
    end

    private

    # called from state_machine before_transition on submit - override in subclass
    #
    def set_allocation_type; end

    def destroy_all_invalid_fee_types; end

    def find_and_associate_documents
      return if self.form_id.nil?

      Document.where(form_id: self.form_id).each do |document|
        document.update_column(:claim_id, self.id)
        document.update_column(:external_user_id, self.external_user_id)
      end
    end

    def last_state_transition_later_than_redetermination?(last_state_transition)
      last_redetermination.nil? ? true : last_redetermination.created_at < last_state_transition.created_at
    end

    def default_values
      self.source ||= 'web'
      self.form_step ||= 1
    end

  end
end

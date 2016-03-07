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
#

module Claim

  class BaseClaimAbstractClassError < RuntimeError
    def initialize(message = 'Claim::BaseClaim is an abstract class and cannot be instantiated')
      super(message)
    end
  end

  class BaseClaim < ActiveRecord::Base

    self.table_name = 'claims'

    auto_strip_attributes :case_number, :cms_number, squish: true, nullify: true

    serialize :evidence_checklist_ids, Array

    include ::Claims::StateMachine
    extend ::Claims::Search
    extend ::Claims::Sort
    include ::Claims::Calculations
    include ::Claims::UserMessages
    include ::Claims::Cloner

    include NumberCommaParser
    numeric_attributes :fees_total, :expenses_total, :total, :vat_amount

    belongs_to :court
    belongs_to :offence
    belongs_to :external_user
    belongs_to :creator, foreign_key: 'creator_id', class_name: 'ExternalUser'
    belongs_to :case_type

    delegate   :provider_id, :provider, to: :creator

    has_many :case_worker_claims,       foreign_key: :claim_id, dependent: :destroy
    has_many :case_workers,             through: :case_worker_claims
    has_many :fees,                     foreign_key: :claim_id, class_name: 'Fee::BaseFee', dependent: :destroy,          inverse_of: :claim
    has_many :fee_types,                through: :fees, class_name: Fee::BaseFeeType
    has_many :expenses,                 foreign_key: :claim_id, dependent: :destroy,          inverse_of: :claim
    has_many :defendants,               foreign_key: :claim_id, dependent: :destroy,          inverse_of: :claim
    has_many :representation_orders,    through: :defendants
    has_many :documents,                foreign_key: :claim_id, dependent: :destroy,          inverse_of: :claim
    has_many :messages,                 foreign_key: :claim_id, dependent: :destroy,          inverse_of: :claim
    has_many :claim_state_transitions,  foreign_key: :claim_id, dependent: :destroy,          inverse_of: :claim

    has_many :basic_fees, foreign_key: :claim_id, class_name: 'Fee::BasicFee', dependent: :destroy, inverse_of: :claim
    has_many :fixed_fees, foreign_key: :claim_id, class_name: 'Fee::FixedFee', dependent: :destroy, inverse_of: :claim
    has_many :misc_fees, foreign_key: :claim_id, class_name: 'Fee::MiscFee', dependent: :destroy, inverse_of: :claim

    has_many :determinations, foreign_key: :claim_id, dependent: :destroy
    has_one  :assessment, foreign_key: :claim_id, dependent: :destroy
    has_many :redeterminations, foreign_key: :claim_id, dependent: :destroy

    has_one  :certification, foreign_key: :claim_id

    has_paper_trail on: [:update], only: [:state]

    # external user relevant scopes
    scope :outstanding, -> { where(state: %w( submitted allocated )) }
    scope :any_authorised,  -> { where(state: %w( part_authorised authorised )) }

    scope :dashboard_displayable_states, -> { where(state: Claims::StateMachine.dashboard_displayable_states) }

    # Trial type scopes
    scope :cracked,     -> { where('case_type_id in (?)', CaseType.ids_by_types('Cracked Trial', 'Cracked before retrial')) }
    scope :trial,       -> { where('case_type_id in (?)', CaseType.ids_by_types('Trial', 'Retrial')) }
    scope :guilty_plea, -> { where('case_type_id in (?)', CaseType.ids_by_types('Guilty plea')) }
    scope :fixed_fee,   -> { where('case_type_id in (?)', CaseType.fixed_fee.map(&:id) ) }

    scope :total_greater_than_or_equal_to, -> (value) { where { total >= value } }
    scope :total_lower_than, -> (value) { where { total < value } }

    accepts_nested_attributes_for :basic_fees,        reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :fixed_fees,        reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :misc_fees,         reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :expenses,          reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :defendants,        reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :assessment
    accepts_nested_attributes_for :redeterminations,  reject_if: :all_blank

    acts_as_gov_uk_date :first_day_of_trial,
                        :trial_concluded_at,
                        :trial_fixed_notice_at,
                        :trial_fixed_at,
                        :trial_cracked_at,
                        :retrial_started_at,
                        :retrial_concluded_at


    before_validation do
      errors.clear
      destroy_all_invalid_fee_types
      documents.each { |d| d.external_user_id = self.external_user_id }
    end


    after_initialize :instantiate_basic_fees,
                     :ensure_not_abstract_class,
                     :default_values,
                     :instantiate_assessment,
                     :set_force_validation_to_false

    after_save :find_and_associate_documents

    def ensure_not_abstract_class
      raise BaseClaimAbstractClassError if self.class == BaseClaim
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

    def earliest_representation_order
      representation_orders.sort do |a, b|
        (a.representation_order_date || 100.years.from_now) <=> (b.representation_order_date || 100.years.from_now)
      end.first
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

    # create a blank fee for every basic fee type not passed to Claim::BaseClaim.new
    def instantiate_basic_fees
      return unless self.new_record?
      existing_basic_fee_type_ids = basic_fees.map(&:fee_type_id)
      basic_fee_types = Fee::BasicFeeType.all
      basic_fee_types.each do |basic_fee_type|
        next if basic_fee_type.id.in?(existing_basic_fee_type_ids)
        self.basic_fees << Fee::BasicFee.new_blank(self, basic_fee_type)
      end
    end

    def has_authorised_state?
      Claims::StateMachine::AUTHORISED_STATES.include?(self.state)
    end

    def state_for_form
      self.state
    end

    def form_input_invalid?(form_input)
      if form_input.blank?
        true
      elsif Claims::InputEventMapper.input_event(form_input) == nil
        raise ArgumentError.new('Only the following state transitions are allowed from form input: allocated to authorised, part_authorised, rejected or refused, part_authorised or refused to redetermination')
      else
        false
      end
    end

    def transition_state(form_input)
      event = Claims::InputEventMapper.input_event(form_input)
      self.send(event) unless form_input == self.state || form_input_invalid?(form_input)
    end

    def update_model_and_transition_state(params)
      form_input = params.delete('state_for_form') # assign param to variable and remove from those used for updating the model
      self.update(params)
      self.transition_state(form_input)
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
      VALID_STATES_FOR_REDETERMINATION.include?(self.state)
    end

    def perform_validation?
      self.force_validation? || self.validation_required?
    end

    # we must validate unless it is being created as draft from any source except API or is in state of archive_pending_delete or deleted
    def validation_required?
      from_api? || !(draft? || archived_pending_delete?)
    end

    def from_api?
      source == 'api'
    end

    def originally_from_api?
      !source.match(/^api/).nil?
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

    def api_draft?
      draft? && from_api?
    end

    def vat_date
      (self.original_submission_date || Date.today).to_date
    end

    def pretty_vat_rate
      VatRate.pretty_rate(self.vat_date)
    end

    def last_state_transition
      claim_state_transitions.order(created_at: :asc).last
    end

    def last_state_transition_time
      last_state_transition.created_at
    end

    def opened_for_redetermination?
      return true if self.redetermination?

      transition = last_state_transition
      transition && transition.from == 'redetermination'
    end

    def written_reasons_outstanding?
      return true if self.awaiting_written_reasons?

      transition = last_state_transition
      transition && transition.from == 'awaiting_written_reasons'
    end

    def amount_assessed
      determinations.last.total_including_vat
    end

    def total_including_vat
      self.total + self.vat_amount
    end

  private

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

    def last_redetermination
      self.redeterminations.select(&:valid?).last
    end

    def destroy_all_invalid_fee_types
      if case_type.present? && case_type.is_fixed_fee?
        basic_fees.map(&:clear) unless basic_fees.empty?
      else
        fixed_fees.destroy_all unless fixed_fees.empty?
      end
    end

    def default_values
      self.source ||= 'web'
    end

    def instantiate_assessment
      self.build_assessment if self.assessment.nil?
    end
  end
end

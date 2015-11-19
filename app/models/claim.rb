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
#  indictment_number        :string
#  first_day_of_trial       :date
#  estimated_trial_length   :integer          default(0)
#  actual_trial_length      :integer          default(0)
#  fees_total               :decimal(, )      default(0.0)
#  expenses_total           :decimal(, )      default(0.0)
#  total                    :decimal(, )      default(0.0)
#  advocate_id              :integer
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
#

class Claim < ActiveRecord::Base
  auto_strip_attributes :case_number, :cms_number, squish: true, nullify: true

  serialize :evidence_checklist_ids, Array

  include Claims::StateMachine
  extend Claims::Search
  include Claims::Calculations
  include Claims::UserMessages
  include Claims::Cloner

  include NumberCommaParser
  numeric_attributes :fees_total, :expenses_total, :total, :vat_amount

  # STATES_FOR_FORM = {
  #   part_authorised: "Part authorised",
  #   authorised: "Authorised",
  #   rejected: "Rejected",
  #   refused: "Refused"
  # }

  belongs_to :court
  belongs_to :offence
  belongs_to :advocate
  belongs_to :creator, foreign_key: 'creator_id', class_name: 'Advocate'
  belongs_to :case_type

  delegate   :chamber_id, to: :advocate

  has_many :case_worker_claims,       dependent: :destroy
  has_many :case_workers,             through: :case_worker_claims
  has_many :fees,                     dependent: :destroy,          inverse_of: :claim
  has_many :fee_types,                through: :fees
  has_many :expenses,                 dependent: :destroy,          inverse_of: :claim
  has_many :defendants,               dependent: :destroy,          inverse_of: :claim
  has_many :documents,                dependent: :destroy,          inverse_of: :claim
  has_many :messages,                 dependent: :destroy,          inverse_of: :claim
  has_many :claim_state_transitions,  dependent: :destroy,          inverse_of: :claim

  has_many :basic_fees,     -> { joins(fee_type: :fee_category).where("fee_categories.abbreviation = 'BASIC'").order(fee_type_id: :asc) }, class_name: 'Fee', inverse_of: :claim
  has_many :fixed_fees,     -> { joins(fee_type: :fee_category).where("fee_categories.abbreviation = 'FIXED'") }, class_name: 'Fee', inverse_of: :claim
  has_many :misc_fees,      -> { joins(fee_type: :fee_category).where("fee_categories.abbreviation = 'MISC'") }, class_name: 'Fee', inverse_of: :claim

  has_many :determinations
  has_one  :assessment
  has_many :redeterminations

  has_one  :certification

  has_paper_trail on: [:update], only: [:state]

  # advocate-relevant scopes
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

  # custom validators
  validates_with ::ValidationInitializer
  validates_with ::ClaimDateValidator
  validates_with ::ClaimTextfieldValidator
  validates_with ::ClaimSubModelValidator

  validate :creator_and_advocate_in_same_chamber

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
                      :trial_cracked_at


  after_initialize :instantiate_basic_fees

  before_save :calculate_vat

  before_validation do
    documents.each { |d| d.advocate_id = self.advocate_id }
  end

  before_validation :destroy_all_invalid_fee_types, :calculate_vat

  after_initialize :default_values, :instantiate_assessment, :set_force_validation_to_false

  after_save :find_and_associate_documents

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
      last_state_transition_later_than_redeterination?(last_state_transition)
    else
      false
    end
  end

  def representation_orders
    self.defendants.map(&:representation_orders).flatten
  end

  def earliest_representation_order
    representation_orders.sort { |a, b| (a.representation_order_date || 100.years.from_now) <=> (b.representation_order_date || 100.years.from_now) }.first
  end

  # responds to methods like claim.advocate_dashboard_submitted? which correspond to the constant ADVOCATE_DASHBOARD_REJECTED_STATES in Claims::StateMachine
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

  # create a blank fee for every basic fee type not passed to Claim.new
  def instantiate_basic_fees
    return unless self.new_record?
    FeeType.basic.each do |basic_fee_type|
      unless self.basic_fees.map(&:fee_type_id).include?(basic_fee_type.id)
        self.basic_fees << Fee.new_blank(self, basic_fee_type)
      end
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
    elsif form_input_to_event[form_input] == nil
      raise ArgumentError.new('Only the following state transitions are allowed from form input: allocated to authorised, part_authorised, rejected or refused, part_authorised or refused to redetermination')
    else
      false
    end
  end

  def form_input_to_event
    { "authorised"               => :authorise!,
      "part_authorised"          => :authorise_part!,
      "rejected"                 => :reject!,
      "refused"                  => :refuse!,
      "redetermination"          => :redetermine!}
  end

  def transition_state(form_input)
    event = form_input_to_event[form_input]
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

  def perform_validation?
    self.force_validation? || self.validation_required?
  end

  # we must validate unless it is being created as draft from any source except API or is in state of archive_pending_delete or deleted
  def validation_required?
    from_api? || (!draft? && !archived_pending_delete? && !deleted?)
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
    if self.apply_vat?
      determinations.last.total + VatRate.vat_amount(determinations.last.total, self.vat_date)
    else
      determinations.last.total
    end
  end

  def total_including_vat
    self.total + self.vat_amount
  end

  private

  def creator_and_advocate_in_same_chamber
    valid = creator_id == advocate_id || creator.try(:chamber) == advocate.try(:chamber)
    errors[:advocate_id] << 'Creator and advocate must belong to the same chamber' unless valid
    valid
  end

  def find_and_associate_documents
    return if self.form_id.nil?

    Document.where(form_id: self.form_id).each do |document|
      document.update_column(:claim_id, self.id)
      document.update_column(:advocate_id, self.advocate_id)
    end
  end

  def last_state_transition_later_than_redeterination?(last_state_transition)
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

  def calculate_vat
    return if self.advocate.nil?
    self.apply_vat = self.advocate.apply_vat
    if self.apply_vat?
      self.vat_amount = VatRate.vat_amount(self.total, self.vat_date)
    else
      self.vat_amount = 0.0
    end
  end
end

# == Schema Information
#
# Table name: claims
#
#  id                     :integer          not null, primary key
#  additional_information :text
#  apply_vat              :boolean
#  state                  :string(255)
#  case_type              :string(255)
#  submitted_at           :datetime
#  case_number            :string(255)
#  advocate_category      :string(255)
#  prosecuting_authority  :string(255)
#  indictment_number      :string(255)
#  first_day_of_trial     :date
#  estimated_trial_length :integer          default(0)
#  actual_trial_length    :integer          default(0)
#  fees_total             :decimal(, )      default(0.0)
#  expenses_total         :decimal(, )      default(0.0)
#  total                  :decimal(, )      default(0.0)
#  advocate_id            :integer
#  court_id               :integer
#  offence_id             :integer
#  scheme_id              :integer
#  created_at             :datetime
#  updated_at             :datetime
#  valid_until            :datetime
#  cms_number             :string(255)
#  paid_at                :datetime
#  creator_id             :integer
#  amount_assessed        :decimal(, )      default(0.0)
#  notes                  :text
#  evidence_notes         :text
#  evidence_checklist_ids :string(255)
#  trial_concluded_at     :date
#  trial_fixed_notice_at  :date
#  trial_fixed_at         :date
#  trial_cracked_at       :date
#  trial_cracked_at_third :string(255)
#  source                 :string(255)
#

class Claim < ActiveRecord::Base
  has_paper_trail

  serialize :evidence_checklist_ids, Array

  include Claims::StateMachine
  extend Claims::Search
  include Claims::Calculations

  attr_reader :offence_class_id

  STATES_FOR_FORM = {
    part_paid: "Part paid",
    paid: "Paid in full",
    rejected: "Rejected",
    refused: "Refused",
    awaiting_info_from_court: "Awaiting info from court"
  }

  belongs_to :court
  belongs_to :offence
  belongs_to :advocate
  belongs_to :creator, foreign_key: 'creator_id', class_name: 'Advocate'
  belongs_to :scheme

  delegate   :chamber_id, to: :advocate

  has_many :case_worker_claims,       dependent: :destroy
  has_many :case_workers,             through: :case_worker_claims
  has_many :fees,                     dependent: :destroy,          inverse_of: :claim
  has_many :fee_types,                through: :fees
  has_many :expenses,                 dependent: :destroy,          inverse_of: :claim
  has_many :defendants,               dependent: :destroy,          inverse_of: :claim
  has_many :documents,                dependent: :destroy,          inverse_of: :claim
  has_many :messages,                 dependent: :destroy,          inverse_of: :claim

  has_many :basic_fees,     -> { joins(fee_type: :fee_category).where("fee_categories.abbreviation = 'BASIC'") }, class_name: 'Fee'
  has_many :non_basic_fees, -> { joins(fee_type: :fee_category).where("fee_categories.abbreviation != 'BASIC'") }, class_name: 'Fee'


  default_scope do
    includes(:advocate,
             :case_workers,
             :court,
             :defendants,
             :documents,
             :expenses,
             :fee_types,
             :messages,
             offence: :offence_class)
  end

  # advocate-relevant scopes
  scope :outstanding, -> { where(state: ['submitted','allocated']) }
  scope :authorised,  -> { where(state: 'paid') }

  # Trial type scopes
  scope :cracked, -> { where(case_type: ['cracked_trial', 'cracked_before_retrial']) }
  scope :trial, -> { where(case_type: ['trial', 'retrial']) }
  scope :guilty_plea, -> { where(case_type: ['guilty_plea']) }

  scope :fixed_fee, -> { joins(fee_types: :fee_category).where('fee_categories.abbreviation = ?', 'FIXED').uniq }

  scope :total_greater_than_or_equal_to, -> (value) { where { total >= value } }

  validates :advocate,                presence: true
  validates :offence,                 presence: true, unless: :do_not_validate?
  validates :creator,                 presence: true, unless: :do_not_validate?
  validates :court,                   presence: true, unless: :do_not_validate?
  validates :scheme,                  presence: true, unless: :do_not_validate?
  validates :case_number,             presence: true, unless: :do_not_validate?
  validates :case_type,               presence: true,     inclusion: { in: Settings.case_types }, unless: :do_not_validate?
  validates :advocate_category,       presence: true,     inclusion: { in: Settings.advocate_categories }, unless: :do_not_validate?
  validates :prosecuting_authority,   presence: true,     inclusion: { in: Settings.prosecuting_authorites }, unless: :do_not_validate?
  validates :estimated_trial_length,  numericality: { greater_than_or_equal_to: 0 }, unless: :do_not_validate?
  validates :actual_trial_length,     numericality: { greater_than_or_equal_to: 0 }, unless: :do_not_validate?
  validates :amount_assessed,         numericality: { greater_than_or_equal_to: 0 }, unless: :do_not_validate?

  validate :amount_assessed_and_state
  validate :evidence_checklist_is_array
  validate :evidence_checklist_ids_all_numeric_strings

  accepts_nested_attributes_for :basic_fees,        reject_if:  :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :non_basic_fees,    reject_if:  proc { |attributes|attrs_blank?(attributes) },  allow_destroy: true
  accepts_nested_attributes_for :expenses,          reject_if: :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :defendants,        reject_if: :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :documents,         reject_if: :all_blank,  allow_destroy: true

  before_validation do
    documents.each { |d| d.advocate_id = self.advocate_id }
  end

  before_validation :set_scheme, unless: :do_not_validate?

  before_save :default_values

  def representation_orders
    self.defendants.map(&:representation_orders).flatten
  end

  def earliest_representation_order
    representation_orders.sort{ |a, b| a.representation_order_date <=> b.representation_order_date }.first
  end


  # responds to methods like claim.advocate_dashboard_submitted? which correspond to the constant ADVOCATE_DASHBOARD_REJECTED_STATES in Claims::StateMachine
  def method_missing(method, *args)
    if Claims::StateMachine.has_state?(method)
      Claims::StateMachine.is_in_state?(method, self)
    else
      super
    end
  end

  def self.attrs_blank?(attributes)
    attributes['quantity'].blank? && attributes['rate'].blank? && attributes['amount'].blank?
  end

  def is_allocated_to_case_worker?(cw)
    self.case_workers.include?(cw)
  end

  def basic_fees
    fees.select { |f| f.is_basic? }.sort{ |a, b| a.fee_type_id <=> b.fee_type_id }
  end

  def instantiate_basic_fees(params = nil)
    return unless self.new_record?
    if params.nil?
      FeeType.basic.each { |fee_type| fees << Fee.new_blank(self, fee_type) }
    else
      Fee.new_collection_from_form_params(self, params)
    end
  end

  def has_paid_state?
    Claims::StateMachine::PAID_STATES.include?(self.state)
  end

  def state_for_form
    self.state
  end

  def form_input_invalid?(form_input)
    if form_input.blank?
      true
    elsif form_input_to_event[form_input] == nil
      raise ArgumentError.new('Only the following state transitions are allowed from form input: allocated to paid, part_paid, rejected, refused or awaiting_info_from_court')
    else
      false
    end
  end

  def form_input_to_event
    { "paid"                     => :pay!,
      "part_paid"                => :pay_part!,
      "rejected"                 => :reject!,
      "refused"                  => :refuse!,
      "awaiting_info_from_court" => :await_info_from_court!}
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
    draft? || submitted?
  end

  def do_not_validate?
    draft? || archived_pending_delete?
  end

  private

  def set_scheme
    rep_order = self.earliest_representation_order

    if rep_order.nil?
      errors[:scheme] << 'Fee scheme cannot be determined as representation order dates have not been entered'
      return
    else
      earliest_rep_order_date = rep_order.representation_order_date
      scheme = Scheme.for_date(earliest_rep_order_date)
      if scheme.nil?
        errors[:scheme] << 'No fee scheme found for entered representation order dates'
        return
      else
        self.scheme_id = scheme.id
      end
    end
  end

  def evidence_checklist_ids_all_numeric_strings
    format_evidence_ids # non-numeric strings will yield a value of 0 and subsequent validation will fail
    if self.evidence_checklist_ids.include?(0)
      errors[:evidence_checklist_ids] << "Invalid"
    end
  end

  def evidence_checklist_is_array
    unless self.evidence_checklist_ids.is_a?(Array)
      raise ActiveRecord::SerializationTypeMismatch.new("Attribute was supposed to be a Array, but was a #{self.evidence_checklist_ids.class}.")
    end
  end

  def format_evidence_ids
    # remove blanks and convert strings to integers
    self.evidence_checklist_ids = self.evidence_checklist_ids.select(&:present?).map(&:to_i)
  end

  def amount_assessed_and_state
    case self.state
      when 'paid', 'part_paid'
        if self.amount_assessed == 0
          errors[:amount_assessed] << "cannot be zero for claims in state #{self.state}"
        end
      when 'awaiting_info_from_court', 'draft', 'refused', 'rejected', 'submitted'
      if self.amount_assessed != 0
        errors[:amount_assessed] << "must be zero for claims in state #{self.state}"
      end
    end
  end

  def default_values
    self.source ||= 'web'
  end

end

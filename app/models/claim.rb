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
#  evidence_notes         :string(255)
#  evidence_checklist_ids :string(255)
#

class Claim < ActiveRecord::Base
  has_paper_trail

  serialize :evidence_checklist_ids, Array

  include Claims::StateMachine
  extend Claims::Search

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

  scope :outstanding, -> { where(state: ['submitted','allocated']) }
  scope :authorised,  -> { where(state: 'paid') }

  validates :advocate,                presence: true
  validates :offence,                 presence: true, unless: :draft?
  validates :creator,                 presence: true, unless: :draft?
  validates :court,                   presence: true, unless: :draft?
  validates :case_number,             presence: true, unless: :draft?
  validates :case_type,               presence: true,     inclusion: { in: Settings.case_types }, unless: :draft?
  validates :advocate_category,       presence: true,     inclusion: { in: Settings.advocate_categories }, unless: :draft?
  validates :prosecuting_authority,   presence: true,     inclusion: { in: Settings.prosecuting_authorites }, unless: :draft?
  validates :estimated_trial_length,  numericality: { greater_than_or_equal_to: 0 }, unless: :draft?
  validates :actual_trial_length,     numericality: { greater_than_or_equal_to: 0 }, unless: :draft?
  validates :amount_assessed,         numericality: { greater_than_or_equal_to: 0 }, unless: :draft?

  validate :amount_assessed_and_state
  validate :evidence_checklist_all_integers

  accepts_nested_attributes_for :basic_fees,        reject_if:  :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :non_basic_fees,    reject_if:  proc { |attributes|attrs_blank?(attributes) },  allow_destroy: true
  accepts_nested_attributes_for :expenses,          reject_if: :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :defendants,        reject_if: :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :documents,         reject_if: :all_blank,  allow_destroy: true

  before_validation do
    documents.each { |d| d.advocate_id = self.advocate_id }
  end

  # responds to methods like claim.advocate_dashboard_submitted? which correspond to the constant ADVOCATE_DASHBOARD_REJECTED_STATES in Claims::StateMachine
  def method_missing(method, *args)
    if Claims::StateMachine.has_state?(method)
      Claims::StateMachine.is_in_state?(method, self)
    else
      super
    end
  end

  def representation_order_dates
    defendants.map(&:representation_order_dates).flatten
  end

  def self.attrs_blank?(attributes)
    attributes['quantity'].blank? && attributes['rate'].blank? && attributes['amount'].blank?
  end

  def is_allocated_to_case_worker?(cw)
    self.case_workers.include?(cw)
  end


  def basic_fees
    fees.select { |f| f.is_basic? }.sort{ |a, b| a.description <=> b.description }
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
    paid_states = Claims::StateMachine::ADVOCATE_DASHBOARD_COMPLETED_STATES + Claims::StateMachine::ADVOCATE_DASHBOARD_PART_PAID_STATES
    paid_states.include?(self.state)
  end

  def state_for_form
    self.state
  end

  def state_for_form=(new_state)
    case new_state
    when 'paid'
      pay!
    when 'part_paid'
      pay_part!
    when 'rejected'
      reject!
    when 'refused'
      refuse!
    when 'awaiting_info_from_court'
      await_info_from_court!
    else
      raise ArgumentError.new('Only the following state transitions are allowed from form input: allocated to paid, part_paid, rejected or refused')
    end
  end

  def calculate_fees_total
    fees.reload.map(&:amount).sum
  end

  def calculate_expenses_total
    expenses.reload.map(&:amount).sum
  end

  def calculate_total
    calculate_fees_total + calculate_expenses_total
  end

  def update_fees_total
    update_column(:fees_total, calculate_fees_total)
  end

  def update_expenses_total
    update_column(:expenses_total, calculate_expenses_total)
  end

  def update_total
    update_column(:total, calculate_total)
  end

  def description
    "#{court.code}-#{case_number} #{advocate.name} (#{advocate.chamber.name})"
  end

  def editable?
    draft? || submitted?
  end

  def update_model_and_transition_state(params)
    new_state = params.delete('state_for_form')
    self.update(params)
    self.state_for_form = new_state unless self.state_for_form == new_state || new_state.blank?
  end

  private

  def evidence_checklist_all_integers
    raise ActiveRecord::SerializationTypeMismatch.new("Attribute was supposed to be a Array, but was a #{self.evidence_checklist_ids.class}.") unless self.evidence_checklist_ids.is_a?(Array)
    self.evidence_checklist_ids = self.evidence_checklist_ids.select(&:present?)
    self.evidence_checklist_ids = self.evidence_checklist_ids.map(&:to_i)
    if self.evidence_checklist_ids.include?(0)
      errors[:evidence_checklist_ids] << "Invalid"
    end
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
end

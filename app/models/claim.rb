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
#

class Claim < ActiveRecord::Base
  has_paper_trail
  include Claims::StateMachine

  attr_reader :offence_class_id

  CASE_TYPES = %w(
                  appeal_against_conviction
                  appeal_against_sentence
                  breach_of_crown_court_order
                  commital_for_sentence
                  contempt
                  cracked_trial
                  cracked_before_retrial
                  discontinuance
                  elected_cases_not_proceeded
                  guilty_plea
                  retrial
                  trial
                )

  ADVOCATE_CATEGORIES = ['QC', 'Led Junior', 'Leading junior', 'Junior alone']

  PROSECUTING_AUTHORITIES = %W( cps )

  STATES_FOR_FORM = {part_paid: "Part paid",
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
             offence: :offence_class).not_deleted
  end

  scope :outstanding, -> { where("state = 'submitted' or state = 'allocated'") }
  scope :authorised, -> { where(state: 'paid') }

  validates :offence,                 presence: true
  validates :advocate,                presence: true
  validates :creator,                 presence: true
  validates :court,                   presence: true
  validates :case_number,             presence: true
  validates :case_type,               presence: true,     inclusion: { in: CASE_TYPES }
  validates :advocate_category,       presence: true,     inclusion: { in: ADVOCATE_CATEGORIES }
  validates :prosecuting_authority,   presence: true,     inclusion: { in: PROSECUTING_AUTHORITIES }
  validates :advocate_category,       presence: true,     inclusion: { in: ADVOCATE_CATEGORIES }
  validates :estimated_trial_length,  numericality: { greater_than_or_equal_to: 0 }
  validates :actual_trial_length,     numericality: { greater_than_or_equal_to: 0 }
  validates :amount_assessed,         numericality: { greater_than_or_equal_to: 0 }

  validate :amount_assessed_and_state

  accepts_nested_attributes_for :basic_fees,        reject_if:  :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :non_basic_fees,    reject_if:  proc { |attributes|attrs_blank?(attributes) },  allow_destroy: true
  accepts_nested_attributes_for :expenses,          reject_if: :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :defendants,        reject_if: :all_blank,  allow_destroy: true
  accepts_nested_attributes_for :documents,         reject_if: :all_blank,  allow_destroy: true

  # after_initialize :instantiate_basic_fees


  def self.attrs_blank?(attributes)
    attributes['quantity'].blank? && attributes['rate'].blank? && attributes['amount'].blank?
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

  def has_doctype?(doc_type)
    documents.pluck(:document_type_id).include?(doc_type.id) #returns boolean
  end

  def doc_of_type(doc_type)
    documents.where(:document_type_id == doc_type.id)[0] #returns an actual document
  end

  class << self

    def find_by_maat_reference(maat_reference)
      joins(:defendants).where('defendants.maat_reference = ?', maat_reference.upcase.strip)
    end

    def find_by_advocate_name(advocate_name)
      joins(advocate: :user)
        .where("lower(users.first_name || ' ' || users.last_name) LIKE ?", "%#{advocate_name.downcase}%")
    end

    def find_by_defendant_name(defendant_name)
      joins(:defendants)
        .where("lower(defendants.first_name || ' ' || defendants.last_name) LIKE ?","%#{defendant_name.downcase}%")
    end

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
    self.state_for_form = new_state
  end

  private

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

class Claim < ActiveRecord::Base
  include Claims::StateMachine

  CASE_TYPES = %w( guilty trial retrial cracked_retrial )
  ADVOCATE_CATEGORIES = %w( qc_alone led_junior leading_junior junior_alone )
  PROSECUTING_AUTHORITIES = %W( cps )

  belongs_to :court
  belongs_to :offence
  belongs_to :advocate
  has_many :case_worker_claims, dependent: :destroy
  has_many :case_workers, through: :case_worker_claims
  has_many :fees, dependent: :destroy, inverse_of: :claim
  has_many :fee_types, through: :fees
  has_many :expenses, dependent: :destroy, inverse_of: :claim
  has_many :defendants, dependent: :destroy, inverse_of: :claim
  has_many :documents, dependent: :destroy, inverse_of: :claim

  validates :offence, presence: true
  validates :advocate, presence: true
  validates :court, presence: true
  validates :case_number, presence: true
  validates :case_type, presence: true, inclusion: { in: CASE_TYPES }
  validates :advocate_category, presence: true, inclusion: { in: ADVOCATE_CATEGORIES }
  validates :prosecuting_authority, presence: true, inclusion: { in: PROSECUTING_AUTHORITIES }
  validates :advocate_category, presence: true, inclusion: { in: ADVOCATE_CATEGORIES }
  validates :indictment_number, presence: true
  validates :estimated_trial_length, numericality: true
  validates :actual_trial_length, numericality: true

  accepts_nested_attributes_for :fees, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :defendants, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true

  class << self
    def find_by_maat_reference(maat_reference)
      joins(:defendants).where('defendants.maat_reference = ?', maat_reference.downcase.strip)
    end
  end

  def calculate_fees_total
    fees.sum(:amount)
  end

  def calculate_expenses_total
    expenses.sum(:amount)
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
    update_column(:total, fees_total + expenses_total)
  end
end

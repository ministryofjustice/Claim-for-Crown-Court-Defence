class Claim < ActiveRecord::Base
  include Claims::StateMachine

  CASE_TYPES = %w{ guilty trial retrial cracked_retrial }

  belongs_to :court
  belongs_to :offence
  belongs_to :advocate, class_name: 'User', inverse_of: :claims_created
  has_many :case_worker_claims, dependent: :destroy
  has_many :case_workers, through: :case_worker_claims, source: :case_worker
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

# == Schema Information
#
# Table name: expense_types
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime
#  updated_at  :datetime
#  roles       :string
#  reason_set  :string
#  unique_code :string
#

class ExpenseType < ApplicationRecord
  ROLES = %w[agfs lgfs].freeze
  include Roles

  REASON_SET_C = {
    1 => ExpenseReason.new(1, 'Court hearing (Crown court)', false),
    2 => ExpenseReason.new(1, 'Court hearing (Magistrates\' court)', false),
    3 => ExpenseReason.new(2, 'Pre-trial conference expert witnesses', false),
    4 => ExpenseReason.new(3, 'Pre-trial conference defendant (prison)', false),
    5 => ExpenseReason.new(3, 'Pre-trial conference defendant (hospital)', false),
    6 => ExpenseReason.new(3, 'Pre-trial conference defendant (other)', false),
    7 => ExpenseReason.new(4, 'View of crime scene', false),
    8 => ExpenseReason.new(5, 'Other', true)
  }.freeze

  REASON_SET_A = {
    1 => ExpenseReason.new(1, 'Court hearing', false),
    2 => ExpenseReason.new(2, 'Pre-trial conference expert witnesses', false),
    3 => ExpenseReason.new(3, 'Pre-trial conference defendant', false),
    4 => ExpenseReason.new(4, 'View of crime scene', false),
    5 => ExpenseReason.new(5, 'Other', true)
  }.freeze

  REASON_SET_B = {
    2 => ExpenseReason.new(2, 'Pre-trial conference expert witnesses', false),
    3 => ExpenseReason.new(3, 'Pre-trial conference defendant', false),
    4 => ExpenseReason.new(4, 'View of crime scene', false)
  }.freeze

  auto_strip_attributes :name, squish: true, nullify: true

  has_many :expenses, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :unique_code, presence: true, uniqueness: { case_sensitive: false }
  validates :reason_set, inclusion: { in: %w[A B C] }

  def self.reason_sets
    [{ A: REASON_SET_A.values }, { B: REASON_SET_B.values }, { C: REASON_SET_C.values }]
  end

  def expense_reasons_hash
    reason_set == 'A' ? REASON_SET_A : REASON_SET_B
  end

  def expense_reasons
    expense_reasons_hash.values
  end

  def expense_reason_by_id(id)
    expense_reasons_hash[id]
  end

  def car_travel?
    name == 'Car travel'
  end

  def bike_travel?
    name == 'Bike travel'
  end

  def parking?
    name == 'Parking'
  end

  def hotel_accommodation?
    name == 'Hotel accommodation'
  end

  def train?
    name == 'Train/public transport'
  end

  def travel_time?
    name == 'Travel time'
  end

  def road_tolls?
    name == 'Road or tunnel tolls'
  end

  def cab_fares?
    name == 'Cab fares'
  end

  def subsistence?
    name == 'Subsistence'
  end

  def self.for_claim_type(claim)
    (claim.lgfs? ? lgfs : agfs).order(:name)
  end
end

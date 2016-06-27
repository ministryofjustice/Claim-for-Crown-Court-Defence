# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  location        :string
#  quantity        :float
#  rate            :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#  reason_id       :integer
#  reason_text     :string
#  schema_version  :integer
#  distance        :decimal(, )
#  mileage_rate_id :integer
#  date            :date
#  hours           :decimal(, )
#  vat_amount      :decimal(, )      default(0.0)
#

class Expense < ActiveRecord::Base

  MILEAGE_RATES = {
    1 => Struct.new(:id, :description).new(1, '25p per mile'),
    2 => Struct.new(:id, :description).new(2, '45p per mile')
  }

  auto_strip_attributes :location, squish: true, nullify: true
  acts_as_gov_uk_date :date, validate_if: :perform_validation?

  include NumberCommaParser
  include Duplicable
  numeric_attributes :rate, :amount, :vat_amount, :quantity, :distance, :hours

  belongs_to :expense_type
  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  has_many :dates_attended, as: :attended_item, dependent: :destroy, inverse_of: :attended_item

  validates_with ExpenseV1Validator, if: :schema_version_1?
  validates_with ExpenseV2Validator, if: :schema_version_2?

  accepts_nested_attributes_for :dates_attended, reject_if: :all_blank, allow_destroy: true

  delegate :car_travel?,
           :parking?,
           :hotel_accommodation?,
           :train?,
           :travel_time?,
           to: :expense_type, allow_nil: true


  before_validation do
    self.schema_version ||= 2
    round_quantity
    self.amount = ((self.rate || 0) * (self.quantity || 0)).abs unless schema_version_2?
  end

  after_save do
    claim.update_expenses_total
    claim.update_total
  end

  after_destroy do
    claim.update_expenses_total
    claim.update_total
    claim.update_vat
  end

  def schema_version_1?
    self.schema_version == 1
  end

  def schema_version_2?
    self.schema_version == 2
  end

  def expense_reason_other?
    expense_reason && expense_reason.reason == 'Other'
  end

  def perform_validation?
    claim&.perform_validation?
  end

  def round_quantity
    self.quantity = (self.quantity*4).round/4.0 if self.quantity
  end

  def expense_reason
    return nil if self.reason_id.nil?
    return nil if self.expense_type.nil?
    expense_type.expense_reason_by_id(self.reason_id)
  end

  def allow_reason_text?
    return false if self.reason_id.nil?
    expense_reason.allow_explanatory_text?
  end

  def expense_reasons
    return [] if expense_type.nil?
    expense_type.expense_reasons
  end

  def displayable_reason_text
    return nil if self.reason_id.nil?
    if allow_reason_text?
      read_attribute(:reason_text)
    else
      expense_reason.reason
    end
  end
end

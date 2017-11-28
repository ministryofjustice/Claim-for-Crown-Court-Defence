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
  CAR_MILEAGE_RATES = {
    1 => Struct.new(:id, :mileage_type, :name, :description, :rate).new(1, :car, '25p', '25p per mile', 0.25),
    2 => Struct.new(:id, :mileage_type, :name, :description, :rate).new(2, :car, '45p', '45p per mile', 0.45)
  }.freeze
  BIKE_MILEAGE_RATES = {
    3 => Struct.new(:id, :mileage_type, :name, :description, :rate).new(3, :bike, '20p', '20p per mile', 0.20)
  }.freeze
  MILEAGE_RATES = CAR_MILEAGE_RATES.merge(BIKE_MILEAGE_RATES)

  auto_strip_attributes :location, squish: true, nullify: true

  acts_as_gov_uk_date :date, validate_if: :perform_validation?, error_clash_behaviour: :override_with_gov_uk_date_field_error

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
           :bike_travel?,
           :parking?,
           :hotel_accommodation?,
           :train?,
           :travel_time?,
           :road_tolls?,
           :cab_fares?,
           :subsistence?,
           to: :expense_type, allow_nil: true

  before_validation do
    self.schema_version ||= 2
    round_quantity
    self.amount = ((rate || 0) * (quantity || 0)).abs unless schema_version_2?
    calculate_vat
  end

  before_save do
    self.amount = 0.0 if amount.nil?
    self.vat_amount = 0.0 if vat_amount.nil?
  end

  after_save do
    claim.update_expenses_total
    claim.update_total
    claim.update_vat
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
    expense_reason&.reason == 'Other'
  end

  def perform_validation?
    claim&.perform_validation?
  end

  def round_quantity
    self.quantity = (quantity * 4).round / 4.0 if quantity
  end

  def mileage_rate
    MILEAGE_RATES[mileage_rate_id]
  end

  def expense_reason
    return nil if reason_id.nil?
    return nil if expense_type.nil?
    expense_type.expense_reason_by_id(reason_id)
  end

  def allow_reason_text?
    expense_reason.present? && expense_reason&.allow_explanatory_text?
  end

  def expense_reasons
    return [] if expense_type.nil?
    expense_type.expense_reasons
  end

  def displayable_reason_text
    return nil if reason_id.nil?
    if allow_reason_text?
      read_attribute(:reason_text)
    else
      expense_reason&.reason
    end
  end

  def expense_type_unique_code=(code)
    self.expense_type = ExpenseType.find_by!(unique_code: code)
  end

  def vat_absent?
    vat_amount.nil? || vat_amount == 0.0
  end

  def vat_present?
    !vat_absent?
  end

  private

  # we only calculate VAT for AGFS claims for vatable providers.  On LGFS claims, the VAT amount is entered in the form.
  def calculate_vat
    return unless claim&.agfs? && amount
    self.vat_amount = VatRate.vat_amount(amount, claim.vat_date, calculate: claim.vat_registered?)
  end
end

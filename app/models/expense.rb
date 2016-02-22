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
#

class Expense < ActiveRecord::Base
  auto_strip_attributes :location, squish: true, nullify: true

  include NumberCommaParser
  include Duplicable
  numeric_attributes :rate, :amount, :quantity

  belongs_to :expense_type
  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  has_many :dates_attended, as: :attended_item, dependent: :destroy, inverse_of: :attended_item

  validates_with ExpenseValidator
  validates_with ExpenseSubModelValidator

  accepts_nested_attributes_for :dates_attended, reject_if: :all_blank, allow_destroy: true

  before_validation do
    round_hours
    self.amount = ((self.rate || 0) * (self.quantity || 0)).abs
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

  def perform_validation?
    claim && claim.perform_validation?
  end

  def round_hours
    self.quantity = (self.quantity*4).round/4.0 if self.quantity
  end

end

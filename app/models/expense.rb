# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  location        :string
#  quantity        :integer
#  rate            :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#

class Expense < ActiveRecord::Base
  auto_strip_attributes :location, squish: true, nullify: true

  include NumberCommaParser
  numeric_attributes :rate, :amount, :quantity

  belongs_to :expense_type
  belongs_to :claim

  has_many :dates_attended, as: :attended_item, dependent: :destroy, inverse_of: :attended_item

  validates :claim, presence: { message: 'Claim cannot be blank' }
  validates_with  ExpenseValidator
  validates_associated :dates_attended, message: 'There is a problem with one or more expense dates attended'

  accepts_nested_attributes_for :dates_attended, reject_if: :all_blank, allow_destroy: true

  before_validation do
    self.amount = ((self.rate || 0) * (self.quantity || 0)).abs
  end

  after_save do
    claim.update_expenses_total
    claim.update_total
  end

  after_destroy do
    claim.update_expenses_total
    claim.update_total
  end

   def perform_validation?
    claim && claim.perform_validation?
  end
end

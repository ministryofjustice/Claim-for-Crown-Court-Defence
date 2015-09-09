# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  location        :string(255)
#  quantity        :integer
#  rate            :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#

class Expense < ActiveRecord::Base
  include NumberCommaParser
  numeric_attributes :rate, :amount, :quantity

  belongs_to :expense_type
  belongs_to :claim

  has_many :dates_attended, as: :attended_item, dependent: :destroy

  validates :expense_type, presence: { message: 'Expense type cannot be blank' }
  validates :claim, presence: { message: "Claim cannot be blank" }
  validates :quantity, presence: {message: "Quantity cannot be blank"}, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :rate, presence: {message: "Rate cannot be blank"}, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

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
end

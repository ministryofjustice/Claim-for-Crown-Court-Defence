# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  date            :datetime
#  location        :string(255)
#  quantity        :integer
#  rate            :decimal(, )
#  hours           :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#

class Expense < ActiveRecord::Base
  belongs_to :expense_type
  belongs_to :claim

  validates :expense_type, presence: true
  validates :claim, presence: true
  validates :quantity, :rate, :hours, presence: true, numericality: { greater_than_or_equal_to: 0 }

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

class Expense < ActiveRecord::Base
  belongs_to :expense_type
  belongs_to :claim

  validates :expense_type, presence: true
  validates :claim, presence: true
  validates_presence_of :quantity, :rate, :hours, :amount

  after_save do
    claim.update_expenses_total
    claim.update_total
  end

  after_destroy do
    claim.update_expenses_total
    claim.update_total
  end
end

class Expense < ActiveRecord::Base
  belongs_to :expense_type
  belongs_to :claim

  validates :expense_type, presence: true
  validates :claim, presence: true
end

class ExpenseType < ActiveRecord::Base
  has_many :expenses, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end

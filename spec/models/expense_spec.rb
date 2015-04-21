require 'rails_helper'

RSpec.describe Expense, type: :model do
  it { should belong_to(:expense_type) }
  it { should belong_to(:claim) }

  it { should validate_presence_of(:expense_type) }
  it { should validate_presence_of(:claim) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:rate) }
  it { should validate_presence_of(:hours) }
  it { should validate_presence_of(:amount) }
end

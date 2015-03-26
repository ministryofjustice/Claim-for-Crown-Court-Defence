require 'rails_helper'

RSpec.describe ExpenseType, type: :model do
  it { should have_many(:expenses) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end

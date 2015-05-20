require 'rails_helper'

RSpec.describe Fee, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:fee_type) }
  it { should validate_presence_of(:quantity) }
  it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
  it { should validate_presence_of(:rate) }
  it { should validate_numericality_of(:rate).is_greater_than_or_equal_to(0) }
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
end

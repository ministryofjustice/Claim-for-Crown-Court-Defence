require 'rails_helper'

RSpec.describe Fee, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:fee_type) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:rate) }
  it { should validate_presence_of(:amount) }
end

require 'rails_helper'

RSpec.describe Fee, type: :model do
  it { should belong_to(:fee_category) }
  it { should have_many(:claim_fees) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:fee_category) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:description) }
  it { should validate_uniqueness_of(:code) }
end

require 'rails_helper'

RSpec.describe Claim, type: :model do
  it { should belong_to(:advocate) }
  it { should have_many(:claim_fees) }
  it { should have_many(:fees) }
  it { should have_many(:expenses) }

  it { should have_many(:case_worker_claims) }
  it { should have_many(:case_workers) }

  it { should validate_presence_of(:advocate) }

  it { should accept_nested_attributes_for(:claim_fees) }
end

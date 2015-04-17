require 'rails_helper'

RSpec.describe ClaimFee, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:fee_type) }
end

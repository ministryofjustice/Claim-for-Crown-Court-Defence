require 'rails_helper'

describe API::Entities::CCR::AdaptedHardshipFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(adapted_hardship_fees).to_json).deep_symbolize_keys }

  let(:claim) { create(:advocate_hardship_claim) }
  let(:adapted_hardship_fees) { ::CCR::Fee::HardshipFeeAdapter.new(claim) }

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'AGFS_ADVANCE',
      bill_subtype: 'AGFS_HARDSHIP',
    )
  end

  it 'exposes calculated fee' do
    expect(response.keys).to include(:calculated_fee)
  end
end

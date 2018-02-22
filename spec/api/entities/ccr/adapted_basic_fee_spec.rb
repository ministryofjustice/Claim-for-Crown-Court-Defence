require 'rails_helper'

describe API::Entities::CCR::AdaptedBasicFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(adapted_basic_fees).to_json).deep_symbolize_keys }

  let(:claim) { create(:authorised_claim) }
  let(:case_type) { instance_double('case_type', fee_type_code: 'GRTRL', requires_retrial_dates?: false) }
  let(:adapted_basic_fees) { ::CCR::Fee::BasicFeeAdapter.new(claim) }

  before do
    allow(claim).to receive(:case_type).and_return case_type
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'AGFS_FEE',
      bill_subtype: 'AGFS_FEE',
      ppe: '0',
      number_of_witnesses: '0',
      number_of_cases: '1',
      daily_attendances: '0',
      case_numbers: nil
    )
  end

  it 'does not expose unneccesary fee attributes' do
    expect(response.keys).not_to include(:quantity, :rate, :amount)
  end
end

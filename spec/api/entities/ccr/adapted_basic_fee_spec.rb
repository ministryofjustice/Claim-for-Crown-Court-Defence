require 'rails_helper'

describe API::Entities::CCR::AdaptedBasicFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(adapted_basic_fees).to_json).deep_symbolize_keys }

  let(:claim) { create(:authorised_claim, case_type: case_type) }
  let(:case_type) { build(:case_type, :trial) }
  let(:adapted_basic_fees) { ::CCR::Fee::BasicFeeAdapter.new(claim) }

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

  context 'when claim is fee scheme 10 discontinuance' do
    subject(:response) { JSON.parse(described_class.represent(adapted_basic_fees).to_json).deep_symbolize_keys }

    let!(:agfs_scheme_ten) { create(:fee_scheme, :agfs_ten) }
    let(:discontinuance) { create(:case_type, :discontinuance) }
    let(:claim) { create(:advocate_claim, :agfs_scheme_10, case_type: discontinuance, prosecution_evidence: true) }
    let(:adapted_basic_fees) { ::CCR::Fee::BasicFeeAdapter.new(claim) }

    it 'exposes expected json key-value pairs' do
      expect(response).to include(ppe: '1')
    end
  end
end

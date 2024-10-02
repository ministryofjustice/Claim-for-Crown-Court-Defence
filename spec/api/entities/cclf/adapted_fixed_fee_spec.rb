require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedFixedFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(fixed_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code: 'FXCBR') }
  let(:case_type) { instance_double(CaseType, fee_type_code: 'FXCBR') }
  let(:claim) { instance_double(Claim::BaseClaim, case_type:) }
  let(:fixed_fee) { instance_double(Fee::FixedFee, claim:, fee_type:, quantity: 10.0) }

  it_behaves_like 'a bill types delegator', CCLF::Fee::FixedFeeAdapter do
    let(:bill) { fixed_fee }
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'LIT_FEE',
      bill_subtype: 'LIT_FEE',
      quantity: '10'
    )
  end
end

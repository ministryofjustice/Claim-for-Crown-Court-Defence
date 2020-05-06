require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedHardshipFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(hardship_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double(Fee::HardshipFeeType, unique_code: 'HARDSHIP') }
  let(:case_type) { instance_double(CaseType, fee_type_code: 'FXCBR') }
  let(:claim) { instance_double(Claim::LitigatorClaim, case_type: case_type) }
  let(:hardship_fee) { instance_double(Fee::HardshipFee, claim: claim, fee_type: fee_type, amount: 111.01, quantity: 300) }

  it_behaves_like 'a bill types delegator', ::CCLF::Fee::HardshipFeeAdapter do
    let(:bill) { hardship_fee }
  end

  it { is_expected.to expose :bill_type }
  it { is_expected.to expose :bill_subtype }
  it { is_expected.to expose :amount }
  it { is_expected.to expose :quantity }

  it 'exposes expected json key-value pairs' do
    is_expected.to include(
      bill_type: 'FEE_ADVANCE',
      bill_subtype: 'HARDSHIP',
      amount: '111.01',
      quantity: '300'
    )
  end
end

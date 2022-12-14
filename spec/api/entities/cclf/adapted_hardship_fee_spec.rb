require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedHardshipFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(hardship_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double(Fee::HardshipFeeType, unique_code: 'HARDSHIP') }
  let(:claim) { instance_double(Claim::LitigatorHardshipClaim) }
  let(:hardship_fee) { instance_double(Fee::HardshipFee, claim:, fee_type:, amount: 111.01, quantity: 300) }

  it_behaves_like 'a bill types delegator', CCLF::Fee::HardshipFeeAdapter do
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

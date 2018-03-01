require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedMiscFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(misc_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double('fee_type', unique_code: 'MISPF') }
  let(:case_type) { instance_double('case_type', fee_type_code: 'GRTRL') }
  let(:claim) { instance_double('claim', case_type: case_type) }
  let(:misc_fee) { instance_double('misc_fee', claim: claim, fee_type: fee_type, amount: 199.50) }

  it_behaves_like 'a bill types delegator', ::CCLF::Fee::MiscFeeAdapter do
    let(:bill) { misc_fee }
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'FEE_SUPPLEMENT',
      bill_subtype: 'SPECIAL_PREP',
      amount: '199.5'
    )
  end
end

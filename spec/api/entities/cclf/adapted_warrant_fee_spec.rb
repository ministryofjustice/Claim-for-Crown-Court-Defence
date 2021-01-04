require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedWarrantFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(warrant_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double(Fee::WarrantFeeType, unique_code: 'WARR') }
  let(:case_type) { instance_double(CaseType, fee_type_code: 'FXCBR') }
  let(:claim) { instance_double(Claim::LitigatorClaim, case_type: case_type) }
  let(:warrant_fee) { instance_double(Fee::WarrantFee, claim: claim, fee_type: fee_type, amount: 111.01, warrant_issued_date: '01-Jun-2017'.to_date, warrant_executed_date: '01-Aug-2017'.to_date) }

  it_behaves_like 'a bill types delegator', ::CCLF::Fee::WarrantFeeAdapter do
    let(:bill) { warrant_fee }
  end

  it { is_expected.to expose :bill_type }
  it { is_expected.to expose :bill_subtype }
  it { is_expected.to expose :warrant_issued_date }
  it { is_expected.to expose :warrant_executed_date }
  it { is_expected.to expose :amount }

  it 'exposes expected json key-value pairs' do
    is_expected.to include(
      bill_type: 'FEE_ADVANCE',
      bill_subtype: 'WARRANT',
      amount: '111.01',
      warrant_issued_date: '2017-06-01',
      warrant_executed_date: '2017-08-01'
    )
  end
end

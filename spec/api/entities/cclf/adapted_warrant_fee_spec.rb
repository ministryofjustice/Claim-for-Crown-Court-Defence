require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedWarrantFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(warrant_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double(Fee::WarrantFeeType, unique_code: 'WARR') }
  let(:case_type) { instance_double(CaseType, fee_type_code: 'FXCBR') }
  let(:claim) { instance_double(Claim::LitigatorClaim, case_type:) }
  let(:warrant_fee) { instance_double(Fee::WarrantFee, claim:, fee_type:, amount: 111.01, warrant_issued_date: Time.zone.today - 90.days, warrant_executed_date: Time.zone.today - 30.days) }

  it_behaves_like 'a bill types delegator', CCLF::Fee::WarrantFeeAdapter do
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
      warrant_issued_date: (Time.zone.today - 90.days).strftime('%Y-%m-%d'),
      warrant_executed_date: (Time.zone.today - 30.days).strftime('%Y-%m-%d')
    )
  end
end

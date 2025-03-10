require 'rails_helper'

RSpec.describe API::Entities::CCR::AdaptedWarrantFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(warrant_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double(Fee::WarrantFeeType, unique_code: 'WARR') }
  let(:claim) { instance_double(Claim::AdvocateInterimClaim) }
  let(:warrant_fee) { instance_double(Fee::WarrantFee, claim:, fee_type:, amount: 111.01, warrant_issued_date: Time.zone.today - 90.days) }

  it_behaves_like 'a bill types delegator', CCR::Fee::WarrantFeeAdapter do
    let(:bill) { warrant_fee }
  end

  it { is_expected.to expose :bill_type }
  it { is_expected.to expose :bill_subtype }
  it { is_expected.not_to expose :case_numbers }
  it { is_expected.to expose :warrant_issued_date }
  it { is_expected.not_to expose :warrant_executed_date }
  it { is_expected.to expose :amount }

  it 'exposes expected json key-value pairs' do
    is_expected.to include(
      bill_type: 'AGFS_ADVANCE',
      bill_subtype: 'AGFS_WARRANT',
      amount: '111.01',
      warrant_issued_date: (Time.zone.today - 90.days).strftime('%Y-%m-%d')
    )
  end
end

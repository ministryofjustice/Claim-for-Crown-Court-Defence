require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedTransferFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(transfer_fee).to_json, symbolize_names: true) }

  let(:claim) { instance_double(::Claim::TransferClaim) }
  let(:fee_type) { instance_double(::Fee::TransferFeeType, unique_code: 'TRANS') }
  let(:transfer_fee) do
    instance_double(
      ::Fee::TransferFee,
      claim: claim,
      fee_type: fee_type,
      quantity: 888.0,
      amount: 303.03
    )
  end

  it_behaves_like 'a bill types delegator', ::CCLF::Fee::TransferFeeAdapter do
    let(:bill) { transfer_fee }
  end

  it 'exposes expected json key-value pairs' do
    is_expected.to match_array(
      bill_type: 'LIT_FEE',
      bill_subtype: 'LIT_FEE',
      quantity: '888',
      amount: '303.03'
    )
  end
end

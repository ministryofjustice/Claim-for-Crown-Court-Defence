require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedInterimFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(interim_fee).to_json, symbolize_names: true) }

  let(:claim) { instance_double(::Claim::InterimClaim) }
  let(:fee_type) { instance_double(::Fee::InterimFeeType, unique_code: 'INTDT') }
  let(:interim_fee) do
    instance_double(
      ::Fee::InterimFee,
      claim: claim,
      fee_type: fee_type,
      quantity: 0.0,
      amount: 0.0,
      warrant_issued_date: nil,
      warrant_executed_date: nil,
      is_interim_warrant?: false
    )
  end

  it_behaves_like 'a bill types delegator', ::CCLF::Fee::InterimFeeAdapter do
    let(:bill) { interim_fee }
  end

  it 'formats amount as string' do
    expect(response).to include(amount: '0.0')
  end

  it 'formats quantity as string integer' do
    expect(response).to include(quantity: '0')
  end

  context 'interim warrants' do
    let(:fee_type) { instance_double(::Fee::InterimFeeType, unique_code: 'INWAR') }

    before do
      allow(interim_fee).to receive_messages(
          amount: 101.01,
          warrant_issued_date: '01-Jun-2017'.to_date,
          warrant_executed_date: '01-Aug-2017'.to_date,
          is_interim_warrant?: true
        )
    end

    it 'exposes expected json key-value pairs' do
      expect(response).to match_array(
        bill_type: 'FEE_ADVANCE',
        bill_subtype: 'WARRANT',
        amount: '101.01',
        quantity: '0',
        warrant_issued_date: '2017-06-01',
        warrant_executed_date: '2017-08-01'
      )
    end
  end

  context 'effective pcmh' do
    let(:fee_type) { instance_double(::Fee::InterimFeeType, unique_code: 'INPCM') }

    before do
      allow(interim_fee).to receive_messages(quantity: 999.0, amount: 202.02)
    end

    it 'exposes expected json key-value pairs' do
      expect(response).to match_array(
        bill_type: 'LIT_FEE',
        bill_subtype: 'LIT_FEE',
        quantity: '999',
        amount: '202.02'
      )
    end

    it 'does not expose warrant attributes' do
       expect(response.keys).not_to include(:warrant_issued_date, :warrant_executed_date)
    end
  end
end

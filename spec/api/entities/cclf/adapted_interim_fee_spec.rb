require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedInterimFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(interim_fee).to_json, symbolize_names: true) }

  let(:claim) { instance_double(::Claim::InterimClaim) }
  let(:fee_type) { instance_double(::Fee::InterimFeeType, unique_code: 'INTDT') }
  let(:interim_fee) { instance_double(::Fee::InterimFee, claim: claim, fee_type: fee_type, quantity: 0.0, amount: 0.0, warrant_issued_date: nil, warrant_executed_date: nil, is_interim_warrant?: false) }
  let(:adapter) { instance_double(::CCLF::Fee::InterimFeeAdapter) }

  it 'formats amount as string' do
    expect(response).to include(amount: '0.0')
  end

  it 'formats quantity as string integer' do
    expect(response).to include(quantity: '0')
  end

  it 'delegates bill types to InterimFeeAdapter' do
    expect(::CCLF::Fee::InterimFeeAdapter).to receive(:new).with(interim_fee).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    subject
  end

  context 'interim warrants' do
    let(:fee_type) { instance_double(::Fee::InterimFeeType, unique_code: 'INWAR') }
    let(:interim_fee) do
      instance_double(
        ::Fee::InterimFee,
        claim: claim,
        fee_type: fee_type,
        quantity: 0.0,
        amount: 101.01,
        warrant_issued_date: '01-Jun-2017'.to_date,
        warrant_executed_date: '01-Aug-2017'.to_date,
        is_interim_warrant?: true
      )
    end

    it 'exposes expected json key-value pairs' do
      expect(response).to include(
        bill_type: 'FEE_ADVANCE',
        bill_subtype: 'WARRANT',
        amount: '101.01',
        quantity: '0',
        warrant_issued_date: "2017-06-01",
        warrant_executed_date: "2017-08-01"
      )
    end
  end

  context 'effective pcmh' do
    let(:fee_type) { instance_double(::Fee::InterimFeeType, unique_code: 'INPCM') }
    let(:interim_fee) { instance_double(::Fee::InterimFee, claim: claim, fee_type: fee_type, quantity: 999.0, amount: 202.02, warrant_issued_date: nil, warrant_executed_date: nil, is_interim_warrant?: false) }

    it 'exposes expected json key-value pairs' do
      expect(response).to include(
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

require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCLF::AdaptedFixedFee do
  subject(:response) { JSON.parse(described_class.represent(fixed_fee).to_json, symbolize_names: true) }

  let(:fxcbr) { create(:fixed_fee_type, :fxcbr) }
  let(:fixed_fee) { instance_double('fixed_fee', claim: nil, fee_type: fxcbr, quantity: 0, amount: 225.50) }

  it 'exposes the required keys' do
    expect(response.keys).to match_array(%i[bill_type bill_subtype bill_scenario amount])
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'LIT_FEE',
      bill_subtype: 'LIT_FEE',
      bill_scenario: 'ST3TS3TB',
      amount: '225.5',
    )
  end

  it 'delegates bill mappings to FixedFeeAdapter' do
    adapter = instance_double(::CCLF::Fee::FixedFeeAdapter)
    expect(::CCLF::Fee::FixedFeeAdapter).to receive(:new).with(fixed_fee).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    expect(adapter).to receive(:bill_scenario)
    subject
  end
end

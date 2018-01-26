require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCLF::AdaptedGraduatedFee do
  subject(:response) { JSON.parse(described_class.represent(graduated_fee).to_json, symbolize_names: true) }

  let(:grtrl) { create(:graduated_fee_type, :grtrl) }
  let(:graduated_fee) { instance_double('graduated_fee', claim: nil, fee_type: grtrl, quantity: 999, amount: 1001.50) }

  it 'exposes the required keys' do
    expect(response.keys).to match_array(%i[bill_type bill_subtype bill_scenario quantity amount])
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'LIT_FEE',
      bill_subtype: 'LIT_FEE',
      bill_scenario: 'ST1TS0T4',
      quantity: '999',
      amount: '1001.5'
    )
  end

  it 'delegates bill mappings to GraduatedFeeAdapter' do
    adapter = instance_double(::CCLF::Fee::GraduatedFeeAdapter)
    expect(::CCLF::Fee::GraduatedFeeAdapter).to receive(:new).with(graduated_fee).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    expect(adapter).to receive(:bill_scenario)
    subject
  end
end

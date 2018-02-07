require 'rails_helper'
require 'spec_helper'

RSpec.describe API::Entities::CCLF::AdaptedFixedFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(fixed_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double('fee_type', unique_code: 'FXCBR') }
  let(:case_type) { instance_double('case_type', fee_type_code: 'FXCBR') }
  let(:claim) { instance_double('claim', case_type: case_type) }
  let(:fixed_fee) { instance_double('fixed_fee', claim: claim, fee_type: fee_type, quantity: 0, amount: 225.50) }
  let(:adapter) { instance_double(::CCLF::Fee::FixedFeeAdapter) }

  it 'exposes the required keys' do
    expect(response.keys).to match_array(%i[bill_type bill_subtype amount vat_included])
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'LIT_FEE',
      bill_subtype: 'LIT_FEE',
      amount: '225.5',
      vat_included: false
    )
  end

  it 'delegates bill mappings to FixedFeeAdapter' do
    expect(::CCLF::Fee::FixedFeeAdapter).to receive(:new).with(fixed_fee).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    expect(adapter).to receive(:vat_included)
    subject
  end
end

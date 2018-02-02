require 'rails_helper'
require 'spec_helper'

RSpec.describe API::Entities::CCLF::AdaptedMiscFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(misc_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double('fee_type', unique_code: 'MISPF') }
  let(:case_type) { instance_double('case_type', fee_type_code: 'GRTRL') }
  let(:claim) { instance_double('claim', case_type: case_type) }
  let(:misc_fee) { instance_double('misc_fee', claim: claim, fee_type: fee_type, amount: 199.50) }

  it 'exposes the required keys' do
    expect(response.keys).to match_array(%i[bill_type bill_subtype bill_scenario amount])
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'FEE_SUPPLEMENT',
      bill_subtype: 'SPECIAL_PREP',
      bill_scenario: 'ST1TS0T4',
      amount: '199.5'
    )
  end

  it 'delegates bill mappings to GraduatedFeeAdapter' do
    adapter = instance_double(::CCLF::Fee::MiscFeeAdapter)
    expect(::CCLF::Fee::MiscFeeAdapter).to receive(:new).with(misc_fee).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    expect(adapter).to receive(:bill_scenario)
    subject
  end
end

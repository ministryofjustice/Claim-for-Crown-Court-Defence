require 'rails_helper'
require 'spec_helper'

RSpec.describe API::Entities::CCLF::AdaptedWarrantFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(warrant_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double('fee_type', unique_code: 'WARR') }
  let(:case_type) { instance_double('case_type', fee_type_code: 'FXCBR') }
  let(:claim) { instance_double('claim', case_type: case_type) }
  let(:warrant_fee) { instance_double('warrant_fee', claim: claim, fee_type: fee_type, amount: 111.01, warrant_issued_date: '01-Jun-2017'.to_date, warrant_executed_date: '01-Aug-2017'.to_date) }
  let(:adapter) { instance_double(::CCLF::Fee::WarrantFeeAdapter) }

  it 'exposes the required keys' do
    expect(response.keys).to match_array(%i[bill_type bill_subtype amount warrant_issued_date warrant_executed_date])
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'FEE_ADVANCE',
      bill_subtype: 'WARRANT',
      amount: '111.01',
      warrant_issued_date: "2017-06-01",
      warrant_executed_date: "2017-08-01"
    )
  end

  it 'delegates bill types to FixedFeeAdapter' do
    expect(::CCLF::Fee::WarrantFeeAdapter).to receive(:new).with(warrant_fee).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    subject
  end
end

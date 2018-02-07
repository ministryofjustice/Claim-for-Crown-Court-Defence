require 'rails_helper'
require 'spec_helper'

RSpec.describe API::Entities::CCLF::AdaptedGraduatedFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(graduated_fee).to_json, symbolize_names: true) }

  let(:fee_type) { instance_double('fee_type', unique_code: 'GRTRL') }
  let(:case_type) { instance_double('case_type', fee_type_code: 'GRTRL') }
  let(:claim) { instance_double('claim', case_type: case_type) }
  let(:graduated_fee) { instance_double('graduated_fee', claim: claim, fee_type: fee_type, quantity: 999, amount: 1001.50) }
  let(:adapter) { instance_double(::CCLF::Fee::GraduatedFeeAdapter) }

  it 'exposes the required keys' do
    expect(response.keys).to match_array(%i[bill_type bill_subtype quantity amount vat_included])
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'LIT_FEE',
      bill_subtype: 'LIT_FEE',
      quantity: '999',
      amount: '1001.5',
      vat_included: false
    )
  end

  it 'delegates bill mappings to GraduatedFeeAdapter' do
    expect(::CCLF::Fee::GraduatedFeeAdapter).to receive(:new).with(graduated_fee).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    expect(adapter).to receive(:vat_included)
    subject
  end
end

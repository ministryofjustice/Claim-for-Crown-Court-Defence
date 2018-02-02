require 'rails_helper'
require 'spec_helper'

RSpec.describe API::Entities::CCLF::AdaptedDisbursement, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(disbursement).to_json, symbolize_names: true) }

  let(:disbursement_type) { instance_double(::DisbursementType, unique_code: 'FOR') }
  let(:case_type) { instance_double(::CaseType, fee_type_code: 'FXACV') }
  let(:claim) { instance_double(::Claim::BaseClaim, case_type: case_type) }
  let(:disbursement) { instance_double(::Disbursement, claim: claim, disbursement_type: disbursement_type, net_amount: 9.99, vat_amount: 1.99) }

  it 'exposes the required keys' do
    expect(response.keys).to match_array(%i[bill_type bill_subtype bill_scenario amount])
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'DISBURSEMENT',
      bill_subtype: 'FORENSICS',
      bill_scenario: 'ST1TS0T5',
      net_amount: '9.99',
      vat_amount: '1.99',
    )
  end

  it 'delegates bill mappings to DisbursementAdapter' do
    adapter = instance_double(::CCLF::DisbursementAdapter)
    expect(::CCLF::DisbursementAdapter).to receive(:new).with(disbursement).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    expect(adapter).to receive(:bill_scenario)
    subject
  end
end

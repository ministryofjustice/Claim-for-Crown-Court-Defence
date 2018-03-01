require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedDisbursement, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(disbursement).to_json, symbolize_names: true) }

  let(:disbursement_type) { instance_double(::DisbursementType, unique_code: 'FOR') }
  let(:case_type) { instance_double(::CaseType, fee_type_code: 'FXACV') }
  let(:claim) { instance_double(::Claim::BaseClaim, case_type: case_type) }
  let(:disbursement) { instance_double(::Disbursement, claim: claim, disbursement_type: disbursement_type, net_amount: 9.99, vat_amount: 1.99) }

  it_behaves_like 'a bill types delegator', ::CCLF::DisbursementAdapter do
    let(:bill) { disbursement }
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'DISBURSEMENT',
      bill_subtype: 'FORENSICS',
      net_amount: '9.99',
      vat_amount: '1.99'
    )
  end
end

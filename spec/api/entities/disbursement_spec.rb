require 'rails_helper'

describe API::Entities::Disbursement do

  let(:disbursement_type) { instance_double(DisbursementType, name: 'Financial expert') }
  let(:disbursement) { instance_double(Disbursement, disbursement_type: disbursement_type, net_amount: 10.45, vat_amount: 5.32, total: 15.77) }

  it 'represents the disbursement entity' do
    result = described_class.represent(disbursement)
    expect(result.to_json).to eq '{"type":"Financial expert","net_amount":10.45,"vat_amount":5.32,"total":15.77}'
  end
end

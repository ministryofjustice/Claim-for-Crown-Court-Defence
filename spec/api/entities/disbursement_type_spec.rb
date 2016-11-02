require 'rails_helper'

describe API::Entities::DisbursementType do

  let(:disbursement_type) { instance_double(::DisbursementType, id: 123, name: 'Computer expert', unique_code: 'COMP') }

  it 'represents the disbursement type entity' do
    result = described_class.represent(disbursement_type).to_json
    expect(result).to eq '{"id":123,"unique_code":"COMP","name":"Computer expert"}'
  end

end
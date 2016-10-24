require 'rails_helper'
require 'spec_helper'

describe API::Entities::CaseWorker do

  let(:case_worker) { instance_double(CaseWorker, id: 1, uuid: 'uuid', first_name: 'Kaia', last_name: 'Casper', email: 'test123@example.com') }

  it 'represents the case_worker entity' do
    result = described_class.represent(case_worker)
    expect(result.to_json).to eq '{"id":1,"uuid":"uuid","first_name":"Kaia","last_name":"Casper","email":"test123@example.com"}'
  end
end

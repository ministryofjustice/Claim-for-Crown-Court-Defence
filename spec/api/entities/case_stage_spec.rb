require 'rails_helper'

describe API::Entities::CaseStage do
  let(:case_stage) { instance_double(CaseStage, id: 1, case_type_id: 8, unique_code: 'PREPTPH', description: 'Pre PTPH', roles: ['agfs']) }

  it 'represents the case stage entity' do
    result = described_class.represent(case_stage).to_json
    expect(result).to eq '{"case_type_id":8,"unique_code":"PREPTPH","description":"Pre PTPH","roles":["agfs"]}'
  end
end

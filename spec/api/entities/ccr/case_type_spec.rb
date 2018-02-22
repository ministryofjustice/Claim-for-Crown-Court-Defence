require 'rails_helper'

describe API::Entities::CCR::CaseType do
  subject(:response) { JSON.parse(described_class.represent(case_type).to_json).deep_symbolize_keys }

  let(:case_type) { build(:case_type, :trial, fee_type_code: 'GRTRL', uuid: 'd6af0535-eee4-4a24-9d20-054f5f48fcec') }

  it 'has expected json key-value pairs' do
    expect(response).to include(uuid: 'd6af0535-eee4-4a24-9d20-054f5f48fcec', bill_scenario: 'AS000004')
  end
end

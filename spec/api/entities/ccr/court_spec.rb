require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCR::Court do
  subject(:response) { JSON.parse(described_class.represent(court).to_json).deep_symbolize_keys }

  let(:court) { build(:court, code: '999') }

  it 'has expected json key-value pairs' do
    expect(response).to include(code: '999')
  end
end

require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCR::DateAttended do
  subject(:response) { JSON.parse(described_class.represent(date_attended).to_json).deep_symbolize_keys }

  let(:date_attended) { build(:date_attended, date: Date.parse('31-01-2017'), date_to: Date.parse('01-02-2017')) }

  it 'has expected json key-value pairs' do
    expect(response).to include(from: '2017-01-31', to: '2017-02-01')
  end
end

require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCR::OffenceClass do
  subject(:response) { JSON.parse(described_class.represent(offence_class).to_json).deep_symbolize_keys }

  let(:offence_class) { build(:offence_class, class_letter: 'E') }

  it 'has expected json key-value pairs' do
    expect(response).to include(class_letter: 'E')
  end
end

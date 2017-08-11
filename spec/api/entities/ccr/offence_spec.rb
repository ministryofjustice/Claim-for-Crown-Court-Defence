require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCR::Offence do
  subject(:response) { JSON.parse(described_class.represent(offence).to_json).deep_symbolize_keys }

  let(:offence_class) { create(:offence_class, class_letter: 'A') }
  let(:offence) { build(:offence, offence_class_id: offence_class.id) }

  it 'has expected json key-value pairs' do
    expect(response).to include(id: 501, offence_class: { class_letter: 'A' })
  end
end

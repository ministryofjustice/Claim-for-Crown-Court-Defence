require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCR::Offence do
  subject(:response) { JSON.parse(described_class.represent(offence).to_json).deep_symbolize_keys }

  let(:offence_class) { create(:offence_class, class_letter: 'C') }
  let(:offence) { build(:offence, unique_code: 'ABOCUT_C', offence_class_id: offence_class.id) }

  it 'has expected json key-value pairs' do
    expect(response).to include(id: 503, unique_code: 'ABOCUT_C', offence_class: { class_letter: 'C' })
  end
end

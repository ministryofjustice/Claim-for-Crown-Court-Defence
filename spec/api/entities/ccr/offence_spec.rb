require 'rails_helper'

describe API::Entities::CCR::Offence do
  subject(:response) { JSON.parse(described_class.represent(offence).to_json).deep_symbolize_keys }

  context 'scheme 9' do
    let(:scheme) { create :fee_scheme, :nine }
    let(:offence_class) { create(:offence_class, class_letter: 'C') }
    let(:offence) { build(:offence, unique_code: 'ABOCUT_C', offence_class_id: offence_class.id) }
    let(:fee_scheme) { create(:fee_scheme, :nine) }

    before {create :offence_fee_scheme, offence: offence, fee_scheme: fee_scheme }

    it 'has expected json key-value pairs' do
      expect(response).to include(unique_code: 'ABOCUT_C', offence_class: { class_letter: 'C' })
    end
  end
end

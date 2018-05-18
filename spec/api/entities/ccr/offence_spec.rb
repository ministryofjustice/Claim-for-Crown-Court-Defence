require 'rails_helper'

describe API::Entities::CCR::Offence do
  subject(:response) { JSON.parse(described_class.represent(offence).to_json).deep_symbolize_keys }

  context 'scheme 9' do
    let(:offence_class) { create(:offence_class, class_letter: 'C') }
    let(:offence) { build(:offence, :with_fee_scheme, unique_code: 'ABOCUT_C', offence_class_id: offence_class.id) }

    it 'has expected json key-value pairs' do
      expect(response).to include(unique_code: 'ABOCUT_C', offence_class: { class_letter: 'C' })
    end
  end

  context 'scheme 10' do
    let(:offence) { build(:offence, :with_fee_scheme_ten, unique_code: 'ACUTY_3.1') }

    it 'has expected json key-value pairs' do
      expect(response).to include(unique_code: 'ACUTY_3.1')
    end
  end
end

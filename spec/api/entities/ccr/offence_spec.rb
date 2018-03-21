require 'rails_helper'

describe API::Entities::CCR::Offence do
  subject(:response) { JSON.parse(described_class.represent(offence).to_json).deep_symbolize_keys }

  context 'scheme 9' do
    let(:scheme) { create :fee_scheme, :agfs_nine }
    let(:offence_class) { create(:offence_class, class_letter: 'C') }
    let(:offence) { build(:offence, unique_code: 'ABOCUT_C', offence_class_id: offence_class.id) }

    before {create :offence_fee_scheme, offence: offence, fee_scheme: scheme }

    it 'has expected json key-value pairs' do
      expect(response).to include(unique_code: 'ABOCUT_C', offence_class: { class_letter: 'C' })
    end
  end

  context 'scheme 10' do
    let(:scheme) { create :fee_scheme }
    let(:fee_band) { create :fee_band, description: 'test fee band'}
    let(:offence) { build(:offence, unique_code: 'ABOCUT_C', fee_band: fee_band) }

    before {create :offence_fee_scheme, offence: offence, fee_scheme: scheme }

    # TODO: identify new codes required by CCR
    xit 'has expected json key-value pairs' do
      expect(response).to include(unique_code: 'ABOCUT_C', fee_band: { name: 'test fee band' })
    end
  end
end

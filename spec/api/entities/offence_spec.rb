require 'rails_helper'

RSpec.describe API::Entities::Offence do
  subject { described_class.represent(offence) }

  context 'when scheme nine' do
    let(:offence) { create(:offence, :with_fee_scheme, offence_class: create(:offence_class, :with_lgfs_offence)) }

    it { expect(JSON.parse(subject.to_json).keys).to eq %w[id description unique_code offence_class_id offence_class] }
  end

  context 'when scheme ten' do
    let(:offence) {
      create(
        :offence, :with_fee_scheme_ten,
        offence_band: create(:offence_band, offence_category: create(:offence_category, number: 6))
      )
    }

    it { expect(JSON.parse(subject.to_json).keys).to eq %w[id description unique_code act_of_law offence_band] }
  end

  context 'when scheme eleven' do
    let(:offence) {
      create(
        :offence, :with_fee_scheme_eleven,
        offence_band: create(:offence_band, offence_category: create(:offence_category, number: 6))
      )
    }

    it { expect(JSON.parse(subject.to_json).keys).to eq %w[id description unique_code act_of_law offence_band] }
  end
end

require 'rails_helper'

RSpec.describe FeeReform::SearchOffences, type: :service do
  let!(:scheme_9_offences) {
    [
      create(:offence, :with_fee_scheme, description: 'Offence 1'),
      create(:offence, :with_fee_scheme, description: 'Offence 3'),
      create(:offence, :with_fee_scheme, description: 'Offence 2')
    ]
  }
  let!(:scheme_10_offences) {
    [
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-1'),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-4 paTTern'),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-5', contrary: 'Matches pattERN'),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-3', offence_band: create(:offence_band, description: 'Bla bla Patterns bla bla')),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-2', offence_band: create(:offence_band, offence_category: create(:offence_category, description: 'PaTterN bla bla')))
    ]
  }

  context 'when no filter is provided' do
    let(:filters) { {} }

    it 'returns all existent offences under fee scheme 10' do
      offences = described_class.call(filters)
      expect(offences.length).to eq(5)
      expect(offences.map(&:description)).to match_array(['Offence 10-1', 'Offence 10-4 paTTern', 'Offence 10-5', 'Offence 10-3', 'Offence 10-2'])
    end
  end

  context 'when search_offence filter is provided' do
    let(:filters) { { search_offence: 'pattern' } }

    it 'returns all offences under fee scheme 10 that match the provided pattern (including band description and category description)' do
      offences = described_class.call(filters)
      expect(offences.length).to eq(4)
      expect(offences.map(&:description)).to match_array(['Offence 10-4 paTTern', 'Offence 10-5', 'Offence 10-3', 'Offence 10-2'])
    end
  end
end

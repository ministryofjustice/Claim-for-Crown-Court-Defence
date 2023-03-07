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
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-1', offence_band: create(:offence_band, description: 'OB-A', number: 1, offence_category: create(:offence_category, description: 'OC-A', number: 1))),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-2 paTTern', offence_band: create(:offence_band, description: 'OB-B', number: 2, offence_category: create(:offence_category, description: 'OC-A', number: 1))),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-3', contrary: 'Matches pattERN', offence_band: create(:offence_band, description: 'OB-A', number: 1, offence_category: create(:offence_category, description: 'OC-Z', number: 12))),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-4', offence_band: create(:offence_band, description: 'Bla bla Patterns bla bla', number: 2, offence_category: create(:offence_category, description: 'OC-C', number: 3))),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-5', offence_band: create(:offence_band, description: 'AAA', number: 1, offence_category: create(:offence_category, description: 'PaTterN bla bla', number: 17)))
    ]
  }
  let!(:scheme_11_offences) {
    [
      create(:offence, :with_fee_scheme_eleven, description: 'Offence 11-1', offence_band: create(:offence_band, description: 'OB-A', number: 1, offence_category: create(:offence_category, description: 'OC-A', number: 1))),
      create(:offence, :with_fee_scheme_eleven, description: 'Offence 11-2 paTTern', offence_band: create(:offence_band, description: 'OB-B', number: 2, offence_category: create(:offence_category, description: 'OC-A', number: 1))),
      create(:offence, :with_fee_scheme_eleven, description: 'Offence 11-3', contrary: 'Matches pattERN', offence_band: create(:offence_band, description: 'OB-A', number: 1, offence_category: create(:offence_category, description: 'OC-Z', number: 12))),
      create(:offence, :with_fee_scheme_eleven, description: 'Offence 11-4', offence_band: create(:offence_band, description: 'Bla bla Patterns bla bla', number: 2, offence_category: create(:offence_category, description: 'OC-C', number: 3))),
      create(:offence, :with_fee_scheme_eleven, description: 'Offence 11-5', offence_band: create(:offence_band, description: 'AAA', number: 1, offence_category: create(:offence_category, description: 'PaTterN bla bla', number: 17)))
    ]
  }
  let!(:scheme_12_offences) {
    [
      create(:offence, :with_fee_scheme_twelve, description: 'Offence 12-1', offence_band: create(:offence_band, description: 'OB-A', number: 1, offence_category: create(:offence_category, description: 'OC-A', number: 1))),
      create(:offence, :with_fee_scheme_twelve, description: 'Offence 12-2 paTTern', offence_band: create(:offence_band, description: 'OB-B', number: 2, offence_category: create(:offence_category, description: 'OC-A', number: 1))),
      create(:offence, :with_fee_scheme_twelve, description: 'Offence 12-3', contrary: 'Matches pattERN', offence_band: create(:offence_band, description: 'OB-A', number: 1, offence_category: create(:offence_category, description: 'OC-Z', number: 12))),
      create(:offence, :with_fee_scheme_twelve, description: 'Offence 12-4', offence_band: create(:offence_band, description: 'Bla bla Patterns bla bla', number: 2, offence_category: create(:offence_category, description: 'OC-C', number: 3))),
      create(:offence, :with_fee_scheme_twelve, description: 'Offence 12-5', offence_band: create(:offence_band, description: 'AAA', number: 1, offence_category: create(:offence_category, description: 'PaTterN bla bla', number: 17)))
    ]
  }

  describe '#call' do
    subject(:results) { described_class.call(filters) }

    context 'with AGFS 10 fee scheme filter' do
      let(:scheme_filter) { 'AGFS 10' }

      context 'with no search_offence filter' do
        let(:filters) { { fee_scheme: scheme_filter } }

        it 'returns all offences for the fee scheme' do
          expect(results.map(&:description)).to contain_exactly('Offence 10-1', 'Offence 10-2 paTTern', 'Offence 10-3', 'Offence 10-4', 'Offence 10-5')
        end
      end
    end

    context 'with AGFS 11 fee scheme filter' do
      let(:scheme_filter) { 'AGFS 11' }

      context 'with search_offence filter' do
        let(:filters) { { fee_scheme: scheme_filter, search_offence: 'pattern' } }

        it 'returns offences for the fee scheme that match the search pattern (including band description and category description)' do
          expect(results.map(&:description)).to contain_exactly('Offence 11-2 paTTern', 'Offence 11-3', 'Offence 11-4', 'Offence 11-5')
        end
      end
    end

    context 'with AGFS 12 fee scheme filter' do
      let(:scheme_filter) { 'AGFS 12' }

      context 'with search_offence filter' do
        let(:filters) { { fee_scheme: scheme_filter, search_offence: 'pattern' } }

        it 'returns offences for the fee scheme that match by description' do
          expect(results.map(&:description)).to include('Offence 12-2 paTTern')
        end

        it 'returns offences for the fee scheme that match by "contrary"' do
          expect(results.map(&:description)).to include('Offence 12-3')
        end

        it 'returns offences for the fee scheme that match by band' do
          expect(results.map(&:description)).to include('Offence 12-4')
        end

        it 'returns offences for the fee scheme that match by category' do
          expect(results.map(&:description)).to include('Offence 12-5')
        end

        it 'does not return offences with no matching description, contrary, band or category' do
          expect(results.map(&:description)).not_to include('Offence 12-1')
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Stats::Graphs::Simple do
  subject(:graph_data) { described_class.new(**options) }

  let(:options) { {} }

  describe '#call' do
    subject(:data_hash) { graph_data.call(&:count) }

    context 'when there are AGFS claims' do

      before do
        create_list(:advocate_claim, 2, :agfs_scheme_9, :submitted)
        create_list(:advocate_claim, 1, :agfs_scheme_10, :submitted)
        create_list(:advocate_claim, 2, :agfs_scheme_11, :submitted)
        create_list(:advocate_claim, 1, :agfs_scheme_12, :submitted)
        create_list(:advocate_claim, 2, :agfs_scheme_13, :submitted)
        create_list(:advocate_claim, 1, :agfs_scheme_14, :submitted)
        create_list(:advocate_claim, 2, :agfs_scheme_15, :submitted)
      end

      it 'returns the correct fee scheme keys and applies the block' do
        is_expected.to eq({ 'AGFS 9' => 2, 'AGFS 10' => 1, 'AGFS 11' => 2, 'AGFS 12' => 1,
                            'AGFS 13' => 2, 'AGFS 14' => 1, 'AGFS 15' => 2 })
      end
    end

    context 'when there are LGFS claims' do
      before do
        create_list(:litigator_claim, 1, :lgfs_scheme_9, :submitted)
        create_list(:litigator_claim, 2, :lgfs_scheme_10, :submitted)
      end

      it 'returns the correct fee scheme keys and applies the block' do
        is_expected.to eq({ 'LGFS 9' => 1, 'LGFS 10' => 2 })
      end
    end

    context 'when there are both AGFS and LGFS claims' do

      before do
        create(:litigator_claim, :lgfs_scheme_10, :submitted)
        create(:advocate_claim, :agfs_scheme_10, :submitted)
        create(:litigator_claim, :lgfs_scheme_9, :submitted)
        create(:advocate_claim, :agfs_scheme_9, :submitted)
      end

      it 'will be in the correct order' do
        expect(data_hash.keys).to eq(['AGFS 9', 'AGFS 10', 'LGFS 9', 'LGFS 10'])
      end
    end

    describe 'date range validation:' do
      before do
        travel_to(Time.zone.parse('2023-08-31')) { create(:litigator_claim, :lgfs_scheme_10, :submitted) }
        travel_to(Time.zone.parse('2023-09-01')) { create(:litigator_claim, :lgfs_scheme_10, :submitted) }
        travel_to(Time.zone.parse('2023-09-30')) { create(:advocate_claim, :agfs_scheme_10, :submitted) }
        travel_to(Time.zone.parse('2023-10-01')) { create(:litigator_claim, :lgfs_scheme_9, :submitted) }
        travel_to(Time.zone.parse('2023-10-01')) { create(:advocate_claim, :agfs_scheme_9, :submitted) }
      end

      context 'when no date range is provided' do
        let(:options) { { from: nil, to: nil } }

        before { travel_to(Time.zone.parse('2023-10-02')) }

        it 'returns only results for the current month' do
          is_expected.to eq({ 'LGFS 9' => 1, 'AGFS 9' => 1 })
        end
      end

      context 'when a valid date range is provided' do
        let(:options) do
          { from: Time.zone.parse('2023-09-01'),
            to: Time.zone.parse('2023-09-30') }
        end

        it 'returns only results for the specified time period' do
          is_expected.to eq({ 'LGFS 10' => 1, 'AGFS 10' => 1 })
        end
      end

      context 'when an inverted date range is provided' do
        let(:options) do
          { from: Time.zone.parse('2023-09-30'),
            to: Time.zone.parse('2023-09-01') }
        end

        before { travel_to(Time.zone.parse('2023-10-02')) }

        it 'returns only results for the current month' do
          is_expected.to eq({ 'LGFS 9' => 1, 'AGFS 9' => 1 })
        end
      end
    end
  end
  describe '#title' do
    subject(:graph_title) { graph_data.title }

    context 'when no dates are provided' do
      let(:options) do
        { from: nil,
          to: nil }
      end

      before { travel_to(Time.zone.parse('2023-10-10')) }

      it { is_expected.to eq('01 Oct - 10 Oct') }
    end

    context 'when dates are provided' do

      let(:options) do
        { from: Time.zone.parse('2023-09-01'),
          to: Time.zone.parse('2023-09-30') }
      end

      it { is_expected.to eq('01 Sep - 30 Sep') }
    end
  end

end

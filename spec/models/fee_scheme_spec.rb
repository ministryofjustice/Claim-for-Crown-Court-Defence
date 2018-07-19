require 'rails_helper'

RSpec.describe FeeScheme, type: :model do
  let!(:lgfs_scheme_nine) { FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs_nine) }
  let!(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine) }
  let!(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme) }

  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:version) }
  it { should validate_presence_of(:name) }

  it { is_expected.to respond_to(:agfs?) }
  it { is_expected.to respond_to(:scheme_10?) }

  describe '.for_claim' do
    subject(:fee_scheme) { described_class.for_claim(claim) }

    describe '#agfs?' do
      subject(:agfs?) { fee_scheme.agfs? }

      context 'for an agfs scheme 10 claim' do
        let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

        it { is_expected.to be_truthy }
      end

      context 'for an lgfs claim' do
        let(:claim) { create(:litigator_claim) }

        it { is_expected.to be_falsey }
      end
    end

    describe '#scheme_10?' do
      subject(:scheme_10?) { fee_scheme.scheme_10? }

      context 'for an agfs scheme 10 claim' do
        let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

        it { is_expected.to be_truthy }
      end

      context 'for an agfs scheme 9 claim' do
        let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

        it { is_expected.to be_falsey }
      end

      context 'for an lgfs claim' do
        let(:claim) { create(:litigator_claim) }

        it { is_expected.to be_falsey }
      end
    end

    context 'for an LGFS claim' do
      let(:claim) { create :litigator_claim }

      it 'returns the default scheme' do
        expect(fee_scheme).to eq(lgfs_scheme_nine)
      end
    end

    context 'for an AGFS claim' do
      let(:claim) { build(:advocate_claim) }

      context 'but there is no representation order dates for the associated defendants' do
        before do
          expect(claim).to receive(:earliest_representation_order).and_return(nil)
        end

        specify { expect(fee_scheme).to be_nil }
      end

      context 'and there is a representation order but its date is not set' do
        let(:representation_order) { instance_double(RepresentationOrder) }

        before do
          expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
          expect(representation_order).to receive(:representation_order_date).and_return(nil)
        end

        specify { expect(fee_scheme).to be_nil }
      end

      context 'and the earliest representation order date is before the AGFS fee reform release date' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:release_date) { 3.months.ago.to_date }

        before do
          expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
          expect(representation_order).to receive(:representation_order_date).and_return(release_date - 1.month)
        end

        specify { expect(fee_scheme).to eq agfs_scheme_nine }
      end

      context 'and the earliest representation order date is in the AGFS fee reform release date' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:release_date) { 3.months.ago.to_date }

        before do
          expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
          expect(representation_order).to receive(:representation_order_date).and_return(release_date)
        end

        specify { expect(fee_scheme).to eq agfs_scheme_ten }
      end

      context 'and the earliest representation order date is after the AGFS fee reform release date' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:release_date) { 3.months.ago.to_date }

        before do
          expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
          expect(representation_order).to receive(:representation_order_date).and_return(release_date + 2.days)
        end

        specify { expect(fee_scheme).to eq agfs_scheme_ten }
      end
    end

    context 'setup for current_Xgfs' do
      describe '.current_agfs' do
        subject(:current_agfs) { described_class.current_agfs }

        context 'when date is before cut over date' do
          it { Timecop.freeze(2018, 3, 10) { is_expected.to eq agfs_scheme_nine } }
        end

        context 'when date is after cut over date' do
          it { Timecop.freeze(2018, 4, 10) { is_expected.to eq agfs_scheme_ten } }
        end
      end

      describe '.current_lgfs' do
        subject(:current_lgfs) { described_class.current_lgfs }

        context 'when date is before cut over date' do
          it { Timecop.freeze(2018, 3, 10) { is_expected.to eq lgfs_scheme_nine } }
        end

        context 'when date is after cut over date' do
          it { Timecop.freeze(2018, 4, 10) { is_expected.to eq lgfs_scheme_nine } }
        end
      end
    end
  end
end

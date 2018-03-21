require 'rails_helper'

RSpec.describe FeeScheme, type: :model do

  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:number) }
  it { should validate_presence_of(:name) }

  describe '.for_claim' do
    subject(:fee_scheme) { described_class.for_claim(claim) }

    let(:claim) { build(:litigator_claim) }

    context 'for a LGFS claim' do
      it 'returns the default scheme' do
        expect(fee_scheme).to eq('default')
      end
    end

    context 'for a AGFS claim' do
      let(:claim) { build(:advocate_claim) }

      context 'when the AGFS fee reform feature is not active' do
        before do
          allow(FeatureFlag).to receive(:active?).with(:agfs_fee_reform).and_return(false)
        end

        it 'returns the default scheme' do
          expect(fee_scheme).to eq('default')
        end
      end

      context 'when the AGFS fee reform feature is active' do
        before do
          allow(FeatureFlag).to receive(:active?).with(:agfs_fee_reform).and_return(true)
        end

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
            expect(Settings).to receive(:agfs_fee_reform_release_date).and_return(release_date.to_s)
            expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
            expect(representation_order).to receive(:representation_order_date).and_return(release_date - 1.month)
          end

          specify { expect(fee_scheme).to eq('default') }
        end

        context 'and the earliest representation order date is in the AGFS fee reform release date' do
          let(:representation_order) { instance_double(RepresentationOrder) }
          let(:release_date) { 3.months.ago.to_date }

          before do
            expect(Settings).to receive(:agfs_fee_reform_release_date).and_return(release_date.to_s)
            expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
            expect(representation_order).to receive(:representation_order_date).and_return(release_date)
          end

          specify { expect(fee_scheme).to eq('fee_reform') }
        end

        context 'and the earliest representation order date is after the AGFS fee reform release date' do
          let(:representation_order) { instance_double(RepresentationOrder) }
          let(:release_date) { 3.months.ago.to_date }

          before do
            expect(Settings).to receive(:agfs_fee_reform_release_date).and_return(release_date.to_s)
            expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
            expect(representation_order).to receive(:representation_order_date).and_return(release_date + 2.days)
          end

          specify { expect(fee_scheme).to eq('fee_reform') }
        end
      end
    end

    context 'setup for current_Xgfs' do

      let!(:lgfs_scheme_nine) { FeeScheme.find_by(name: 'LGFS', number: 9) || create(:fee_scheme, :lgfs_nine) }
      let!(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', number: 9) || create(:fee_scheme, :agfs_nine) }
      let!(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', number: 10) || create(:fee_scheme) }

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

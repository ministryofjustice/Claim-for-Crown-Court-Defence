require 'rails_helper'

RSpec.describe FeeScheme, type: :model do
  before do
    seed_fee_schemes
  end

  let(:lgfs_scheme_nine) { FeeScheme.find_by(name: 'LGFS', version: 9) }
  let(:lgfs_scheme_ten) { FeeScheme.find_by(name: 'LGFS', version: 10) }
  let(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', version: 9) }
  let(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', version: 10) }
  let(:agfs_scheme_eleven) { FeeScheme.find_by(name: 'AGFS', version: 11) }
  let(:agfs_scheme_twelve) { FeeScheme.find_by(name: 'AGFS', version: 12) }
  let(:fee_scheme) { described_class.for_claim(claim) }

  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:version) }
  it { should validate_presence_of(:name) }

  it { is_expected.to respond_to(:agfs?, :agfs_reform?, :agfs_scheme_12?) }

  describe '#agfs?' do
    subject(:agfs?) { fee_scheme.agfs? }

    context 'with an agfs scheme 10 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      it { is_expected.to be_truthy }
    end

    context 'with an lgfs claim' do
      let(:claim) { create(:litigator_claim) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#agfs_reform?' do
    subject(:agfs_reform?) { fee_scheme.agfs_reform? }

    context 'with an agfs scheme 10 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      it { is_expected.to be_truthy }
    end

    context 'with an agfs scheme 9 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

      it { is_expected.to be_falsey }
    end

    context 'with an lgfs claim' do
      let(:claim) { create(:litigator_claim) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#agfs_scheme_12?' do
    subject { fee_scheme.agfs_scheme_12? }

    context 'with an agfs scheme 12 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_12) }

      it { is_expected.to be_truthy }
    end

    context 'with an agfs scheme 10 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      it { is_expected.to be_falsey }
    end

    context 'with an agfs scheme 9 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

      it { is_expected.to be_falsey }
    end

    context 'with an lgfs claim' do
      let(:claim) { create(:litigator_claim) }

      it { is_expected.to be_falsey }
    end
  end

  describe '.current_agfs' do
    subject(:current_agfs) { described_class.current_agfs }

    around do |example|
      travel_to the_date do
        example.run
      end
    end

    context 'when date is just before scheme 10 cut over date' do
      let(:the_date) { Date.new(2018, 3, 31) }

      it { is_expected.to eq agfs_scheme_nine }
    end

    context 'when date is on/after scheme 10 cut over date' do
      let(:the_date) { Date.new(2018, 4, 1) }

      it { is_expected.to eq agfs_scheme_ten }
    end

    context 'when date is just before scheme 11 cut over date' do
      let(:the_date) { Date.new(2018, 12, 30) }

      it { is_expected.to eq agfs_scheme_ten }
    end

    context 'when date is on/after scheme 11 cut over date' do
      let(:the_date) { Date.new(2018, 12, 31) }

      it { is_expected.to eq agfs_scheme_eleven }
    end

    context 'when date is just before scheme 12 cut over date' do
      let(:the_date) { Date.new(2020, 9, 16) }

      it { is_expected.to eq agfs_scheme_eleven }
    end

    context 'when date is on/after scheme 12 cut over date' do
      let(:the_date) { Date.new(2020, 9, 17) }

      it { is_expected.to eq agfs_scheme_twelve }
    end
  end

  describe '.current_lgfs' do
    subject(:current_lgfs) { described_class.current_lgfs }

    around do |example|
      travel_to the_date do
        example.run
      end
    end

    context 'when date is before cut over date' do
      let(:the_date) { Date.new(2018, 3, 10) }

      it { is_expected.to eq lgfs_scheme_nine }
    end

    context 'when date is after cut over date but before the start date of scheme 10' do
      let(:the_date) { Date.new(2018, 4, 10) }

      it { is_expected.to eq lgfs_scheme_nine }
    end

    context 'when date is on or after the start date for scheme 10' do
      let(:the_date) { Settings.lgfs_scheme_10_clair_release_date }

      it { is_expected.to eq lgfs_scheme_ten }
    end
  end

  describe '.for_claim' do
    subject(:fee_scheme) { described_class.for_claim(claim) }

    context 'with an LGFS claim' do
      let(:claim) { create :litigator_claim }

      context 'without representation order' do
        before do
          expect(claim).to receive(:earliest_representation_order).and_return(nil)
        end

        it { is_expected.to be_nil }
      end

      context 'with representation order but no date' do
        let(:representation_order) { instance_double(RepresentationOrder) }

        before do
          expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
          expect(representation_order).to receive(:representation_order_date).and_return(nil)
        end

        it { is_expected.to be_nil }
      end

      context 'with offence but no representation order' do
        let(:claim) { create(:litigator_claim, offence:) }

        before do
          allow(claim).to receive(:earliest_representation_order).and_return(nil)
        end

        context 'with fee scheme 9 offence' do
          let(:offence) { create(:offence, :with_lgfs_fee_scheme_nine) }

          it { is_expected.to eq lgfs_scheme_nine }
        end

        context 'with fee scheme 10 offence' do
          let(:offence) { create(:offence, :with_lgfs_fee_scheme_ten) }

          it { is_expected.to eq lgfs_scheme_ten }
        end
      end

      context 'when the earliest representation order date is before the start date of scheme 9' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:representation_order_date) { Date.new(2018, 3, 10) }

        before do
          allow(claim).to receive(:earliest_representation_order).and_return(representation_order)
          allow(representation_order).to receive(:representation_order_date).and_return(representation_order_date)
        end

        it { is_expected.to eq lgfs_scheme_nine }
      end

      context 'when the earliest rep order date is between the start date of scheme 9 but before scheme 10' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:representation_order_date) { Date.new(2018, 4, 1) }

        before do
          allow(claim).to receive(:earliest_representation_order).and_return(representation_order)
          allow(representation_order).to receive(:representation_order_date).and_return(representation_order_date)
        end

        it { is_expected.to eq lgfs_scheme_nine }
      end

      context 'when the earliest representation order date is on or after the start date of scheme 10' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:representation_order_date) { Settings.lgfs_scheme_10_clair_release_date }

        before do
          allow(claim).to receive(:earliest_representation_order).and_return(representation_order)
          allow(representation_order).to receive(:representation_order_date).and_return(representation_order_date)
        end

        it { is_expected.to eq lgfs_scheme_ten }
      end
    end

    context 'with an AGFS claim' do
      let(:claim) { build(:advocate_claim) }

      context 'without representation order' do
        before do
          expect(claim).to receive(:earliest_representation_order).and_return(nil)
        end

        specify { expect(fee_scheme).to be_nil }
      end

      context 'with representation order but no date' do
        let(:representation_order) { instance_double(RepresentationOrder) }

        before do
          expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
          expect(representation_order).to receive(:representation_order_date).and_return(nil)
        end

        specify { expect(fee_scheme).to be_nil }
      end

      context 'with offence but no representation order' do
        let(:claim) { create(:advocate_claim, offence:) }

        before do
          allow(claim).to receive(:earliest_representation_order).and_return(nil)
        end

        context 'with fee scheme 9 offence' do
          let(:offence) { create(:offence, :with_fee_scheme_nine) }

          specify { expect(fee_scheme).to eql agfs_scheme_nine }
        end

        context 'with fee scheme 10 offence' do
          let(:offence) { create(:offence, :with_fee_scheme_ten) }

          specify { expect(fee_scheme).to eql agfs_scheme_ten }
        end

        context 'with fee scheme 11 offence' do
          let(:offence) { create(:offence, :with_fee_scheme_eleven) }

          specify { expect(fee_scheme).to eql agfs_scheme_eleven }
        end

        context 'with fee scheme 12 offence' do
          let(:offence) { create(:offence, :with_fee_scheme_twelve) }

          specify { expect(fee_scheme).to eql agfs_scheme_twelve }
        end
      end

      context 'when the earliest representation order date is before the AGFS fee reform release date' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:release_date) { Settings.agfs_fee_reform_release_date }

        before do
          expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
          expect(representation_order).to receive(:representation_order_date).and_return(release_date - 1.month)
        end

        specify { expect(fee_scheme).to eq agfs_scheme_nine }
      end

      context 'when the earliest representation order date is on/after the AGFS fee reform release date' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:release_date) { Settings.agfs_fee_reform_release_date }

        before do
          allow(claim).to receive(:earliest_representation_order).and_return(representation_order)
          allow(representation_order).to receive(:representation_order_date).and_return(release_date)
        end

        specify { expect(fee_scheme).to eq agfs_scheme_ten }
      end

      context 'when the earliest representation order date is on/after the AGFS scheme 11 release date' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:release_date) { Settings.agfs_scheme_11_release_date }

        before do
          allow(claim).to receive(:earliest_representation_order).and_return(representation_order)
          allow(representation_order).to receive(:representation_order_date).and_return(release_date)
        end

        specify { expect(fee_scheme).to eq agfs_scheme_eleven }
      end

      context 'when the earliest representation order date is on/after the CLAR (AGFS scheme 12) release date' do
        let(:representation_order) { instance_double(RepresentationOrder) }
        let(:release_date) { Settings.clar_release_date.beginning_of_day }

        before do
          expect(claim).to receive(:earliest_representation_order).and_return(representation_order)
          expect(representation_order).to receive(:representation_order_date).and_return(release_date)
        end

        specify { expect(fee_scheme).to eq agfs_scheme_twelve }
      end
    end
  end
end

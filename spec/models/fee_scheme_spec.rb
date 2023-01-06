require 'rails_helper'

RSpec.describe FeeScheme do
  let(:lgfs_scheme_nine) { FeeScheme.find_by(name: 'LGFS', version: 9) }
  let(:lgfs_scheme_ten) { FeeScheme.find_by(name: 'LGFS', version: 10) }
  let(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', version: 9) }
  let(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', version: 10) }
  let(:agfs_scheme_eleven) { FeeScheme.find_by(name: 'AGFS', version: 11) }
  let(:agfs_scheme_twelve) { FeeScheme.find_by(name: 'AGFS', version: 12) }
  let(:agfs_scheme_thirteen) { FeeScheme.find_by(name: 'AGFS', version: 13) }
  let(:fee_scheme) { claim.fee_scheme }

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

    context 'with an agfs scheme 13 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_13) }

      it { is_expected.to be_falsey }
    end

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

  describe '#agfs_scheme_13?' do
    subject { fee_scheme.agfs_scheme_13? }

    context 'with an agfs scheme 13 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_13) }

      it { is_expected.to be_truthy }
    end

    context 'with an agfs scheme 12 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_12) }

      it { is_expected.to be_falsey }
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
end

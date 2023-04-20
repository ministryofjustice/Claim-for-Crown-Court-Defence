require 'rails_helper'

describe Fee::MiscFeePresenter do
  subject(:presenter) { described_class.new(misc_fee, view) }

  describe '#rate' do
    subject { presenter.rate }

    context 'with an AGFS claim and calculated fee type' do
      let(:misc_fee) { create(:misc_fee, rate: 12.01, claim: build(:advocate_claim)) }

      before { allow(misc_fee).to receive(:calculated?).and_return(true) }

      it { is_expected.to eq('£12.01') }
    end

    context 'with an AGFS claim and uncalculated fee type' do
      let(:misc_fee) { create(:misc_fee, rate: 12.01, claim: build(:advocate_claim)) }

      before { allow(misc_fee).to receive(:calculated?).and_return(false) }

      it { is_expected.to match(%r{n/a}) }
    end

    context 'with a section 28 fee (MISTE)' do
      let(:misc_fee) do
        create(:misc_fee, rate: 12.01, claim: build(:advocate_claim), fee_type: build(:misc_fee_type, :miste))
      end

      it { is_expected.to match(%r{n/a}) }
    end

    context 'with an LGFS claim' do
      let(:misc_fee) { create(:misc_fee, rate: 12.01, claim: build(:litigator_claim)) }

      before { allow(misc_fee).to receive(:calculated?).and_return(true) }

      it { is_expected.to match(%r{n/a}) }
    end

    context 'without a fee type' do
      let(:misc_fee) { build(:misc_fee, rate: 12.01, fee_type: nil) }

      before { allow(misc_fee).to receive(:calculated?).and_return(true) }

      it { is_expected.to eq('£12.01') }
    end
  end

  describe '#quantity' do
    subject { presenter.quantity }

    context 'with an AGFS claim' do
      let(:misc_fee) { create(:misc_fee, quantity: 77, claim: build(:advocate_claim)) }

      it { is_expected.to eq('77') }
    end

    context 'with a section 28 fee (MISTE)' do
      let(:misc_fee) do
        create(:misc_fee, quantity: 77, claim: build(:advocate_claim), fee_type: build(:misc_fee_type, :miste))
      end

      it { is_expected.to match(%r{n/a}) }
    end

    context 'with an LGFS claim' do
      let(:misc_fee) { create(:misc_fee, quantity: 77, claim: build(:litigator_claim)) }

      it { is_expected.to match(%r{n/a}) }
    end

    context 'without a fee type' do
      let(:misc_fee) { build(:misc_fee, quantity: 77, fee_type: nil) }

      before { allow(misc_fee).to receive(:calculated?).and_return(true) }

      it { is_expected.to eq('77') }
    end
  end
end

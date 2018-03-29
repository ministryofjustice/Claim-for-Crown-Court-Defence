require 'rails_helper'

RSpec.describe Fee::BasicFeePresenter, type: :presenter do
  let(:claim) { build(:advocate_claim) }
  let(:fee) { build(:basic_fee, claim: claim) }

  subject(:presenter) { described_class.new(fee, view) }

  describe '#prompt_text' do
    context 'when the fee type code does not require a prompt text' do
      let(:fee) { build(:basic_fee, :daf_fee, claim: claim) }

      specify { expect(presenter.prompt_text).to be_nil }
    end

    context 'when the fee type code is BAF' do
      let(:fee) { build(:basic_fee, :baf_fee, claim: claim) }

      specify { expect(presenter.prompt_text).to eq("Please include dates for those Standard appearance fees and PTPH's included in the Basic Fee\n") }

      context 'and the claim is under the fee reform scheme' do
        before do
          allow(claim).to receive(:fee_scheme).and_return('fee_reform')
        end

        specify { expect(presenter.prompt_text).to eq("The basic fee for Scheme 10 claims includes the first day of trial and 3 conferences and views. All other hearings must be added in the relevant sections below\n") }
      end
    end

    context 'when the fee type code is SAF' do
      let(:fee) { build(:basic_fee, :saf_fee, claim: claim) }

      specify { expect(presenter.prompt_text).to eq("Include any additional PTPH fees under SAF") }

      context 'and the claim is under the fee reform scheme' do
        before do
          allow(claim).to receive(:fee_scheme).and_return('fee_reform')
        end

        specify { expect(presenter.prompt_text).to be_nil }
      end
    end
  end

  describe '#display_amount?' do
    context 'when the associated claim is not under the new fee reform' do
      before do
        expect(claim).to receive(:fee_scheme).and_return('default')
      end

      specify { expect(presenter.display_amount?).to be_truthy }
    end

    context 'when the associated claim is under the new fee reform' do
      before do
        expect(claim).to receive(:fee_scheme).and_return('fee_reform')
      end

      context 'but the fee type code is not included in the blacklist' do
        let(:fee) { build(:basic_fee, :baf_fee, claim: claim) }

        specify { expect(presenter.display_amount?).to be_truthy }
      end

      context 'but the fee type code is blacklisted' do
        let(:fee) { build(:basic_fee, :ppe_fee, claim: claim) }

        specify { expect(presenter.display_amount?).to be_falsey }
      end
    end
  end
end

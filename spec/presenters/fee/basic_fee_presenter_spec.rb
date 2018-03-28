require 'rails_helper'

RSpec.describe Fee::BasicFeePresenter, type: :presenter do
  let(:claim) { build(:advocate_claim) }
  let(:fee) { build(:basic_fee, claim: claim) }

  subject(:presenter) { described_class.new(fee, view) }

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

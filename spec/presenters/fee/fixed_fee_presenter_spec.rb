require 'rails_helper'

RSpec.describe Fee::FixedFeePresenter do
  let(:claim) { create(:advocate_claim) }
  let(:fixed_fee) { instance_double(Fee::FixedFee, claim:, quantity_is_decimal?: false, errors: { quantity: [] }) }
  let(:presenter) { Fee::FixedFeePresenter.new(fixed_fee, view) }

  context '#rate' do
    context 'for AGFS claims' do
      it 'returns number as currency for calculated fees' do
        allow(fixed_fee).to receive(:calculated?).and_return true
        expect(fixed_fee).to receive(:rate).and_return 12.02
        expect(presenter.rate).to eq '£12.02'
      end

      it 'return not_applicable for uncalculated fees' do
        allow(fixed_fee).to receive(:calculated?).and_return false
        expect(presenter).to receive(:not_applicable)
        presenter.rate
      end
    end

    context 'for LGFS claims' do
      let(:claim) { create(:litigator_claim) }

      it 'returns number as currency for calculated fees' do
        allow(fixed_fee).to receive(:calculated?).and_return true
        expect(fixed_fee).to receive(:rate).and_return 12.03
        expect(presenter.rate).to eq '£12.03'
      end

      it 'return not_applicable for uncalculated fees' do
        allow(fixed_fee).to receive(:calculated?).and_return false
        expect(presenter).to receive(:not_applicable)
        presenter.rate
      end
    end
  end

  context '#quantity' do
    context 'for AGFS claims' do
      it 'returns the raw fee quantity' do
        expect(fixed_fee).to receive(:quantity)
        presenter.quantity
      end
    end

    context 'for LGFS claims' do
      let(:claim) { create(:litigator_claim) }

      it 'returns the raw fee quantity' do
        expect(fixed_fee).to receive(:quantity)
        presenter.quantity
      end
    end
  end
end

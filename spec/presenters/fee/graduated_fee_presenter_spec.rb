require 'rails_helper'

describe Fee::GraduatedFeePresenter do
  let(:claim) { instance_double(Claim::BaseClaim, actual_trial_length: 51) }
  let(:grad_fee) { instance_double(Fee::GraduatedFee, claim:, quantity_is_decimal?: false, errors: { quantity: [] }) }
  let(:presenter) { Fee::GraduatedFeePresenter.new(grad_fee, view) }

  describe '#rate' do
    it 'calls not_applicable' do
      expect(presenter).to receive(:not_applicable)
      presenter.rate
    end
  end

  describe '#quantity' do
    it 'returns fee quantity' do
      expect(grad_fee).to receive(:quantity).and_return 12
      expect(presenter.quantity).to eq '12'
    end
  end

  describe '#days_claimed' do
    it 'sends actual_trial_length to claim' do
      expect(claim).to receive(:actual_trial_length)
      expect(presenter.days_claimed).to eq 51
    end
  end
end

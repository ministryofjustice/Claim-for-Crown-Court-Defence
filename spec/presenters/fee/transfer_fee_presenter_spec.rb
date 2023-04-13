require 'rails_helper'

RSpec.describe Fee::TransferFeePresenter do
  let(:claim) { instance_double(Claim::BaseClaim) }
  let(:transfer_fee) { instance_double(Fee::TransferFee, claim:) }
  let(:presenter) { described_class.new(transfer_fee, view) }

  describe '#rate' do
    it 'sends message #not_applicable' do
      expect(presenter).to receive(:not_applicable)
      presenter.rate
    end
  end

  describe '#days_claimed' do
    subject(:days_claimed) { presenter.days_claimed }

    it 'sends message to #claim.actual_trial_length' do
      expect(presenter).to receive(:claim).and_return claim
      expect(claim).to receive(:actual_trial_length)
      days_claimed
    end
  end
end

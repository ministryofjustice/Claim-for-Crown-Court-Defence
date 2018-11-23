require 'rails_helper'

RSpec.describe Fee::BaseFeePresenter, type: :presenter do
  let(:claim) { instance_double(Claim::BaseClaim) }
  let(:fee) { instance_double(Fee::BaseFee, claim: claim) }

  subject(:presenter) { described_class.new(fee, view) }

  describe '#display_amount?' do
    subject(:display_amount?) { presenter.display_amount? }
    it { is_expected.to be_truthy }
  end

  describe '#days_claimed' do
    subject(:days_claimed) { presenter.days_claimed }

    it 'sends message #not_applicable' do
      expect(presenter).to receive(:not_applicable)
      days_claimed
    end
  end
end

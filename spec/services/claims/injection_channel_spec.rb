require 'rails_helper'

RSpec.describe Claims::InjectionChannel, type: :service do
  subject(:injection_channel) { described_class.for(claim) }

  context 'when claim type can not be inferred' do
    let(:claim) { nil }

    it { is_expected.to eql('cccd_development') }
  end

  context 'when a response_queue name matches live-1 SQS name' do
    before { allow(Settings.aws).to receive(:response_queue).and_return('laa-get-paid-test-responses-for-cccd') }
    let(:claim) { create(:litigator_claim) }

    it { is_expected.to eql('cccd-k8s-injection') }
  end

  context 'when claim is for LGFS' do
    let(:claim) { create(:litigator_claim) }

    it { is_expected.to eql('cccd_cclf_injection') }
  end

  context 'when claim is for AGFS' do
    let(:claim) { create(:claim) }

    it { is_expected.to eql('cccd_ccr_injection') }
  end
end

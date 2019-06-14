require 'rails_helper'

RSpec.describe Claims::InjectionChannel, type: :service do
  subject(:injection_channel) { described_class.for(claim) }

  context 'when a response_queue_url setting exists' do
    before { allow(Settings.aws.sqs).to receive(:response_queue_url).and_return('http://test.aws.queue') }
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

  context 'when claim type can not be inferred' do
    let(:claim) { nil }

    it { is_expected.to eql('cccd_development') }
  end
end

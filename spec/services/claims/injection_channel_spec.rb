require 'rails_helper'

RSpec.describe Claims::InjectionChannel, type: :service do
  subject(:injection_channel) { described_class.for(claim) }

  before { allow(Settings).to receive_message_chain(:slack, :channel).and_return('ccr_target_channel') }

  context 'when claim is for LGFS' do
    let(:claim) { create(:litigator_claim) }

    it { is_expected.to eql('cccd_cclf_injection') }
  end

  context 'when claim is for AGFS' do
    let(:claim) { create(:claim) }

    it { is_expected.to eql('ccr_target_channel') }
  end

  context 'when claim type can not be inferred' do
    let(:claim) { nil }

    it { is_expected.to eql('cccd_development') }
  end
end

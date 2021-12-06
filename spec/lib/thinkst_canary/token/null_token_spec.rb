require 'rails_helper'

RSpec.describe ThinkstCanary::Token::NullToken do
  subject(:token) { described_class.new(**token_options) }

  let(:token_options) { { memo: 'Null token', kind: 'unknown' } }

  describe '.new' do
    before do
      allow(ThinkstCanary.configuration)
        .to receive(:query)
        .and_return({ 'canarytoken' => { 'canarytoken' => 'canarytoken' } })

      token
    end

    it { expect(ThinkstCanary.configuration).not_to have_received(:query) }
  end

  describe '#canarytoken' do
    subject { token.canarytoken }

    it { is_expected.to eq("Unknown Canary kind 'unknown'") }
  end
end

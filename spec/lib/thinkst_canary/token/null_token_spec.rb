require 'rails_helper'

RSpec.describe ThinkstCanary::Token::NullToken do
  subject(:token) { described_class.new(**token_options) }

  let(:token_options) { { memo: 'Null token', kind: 'unknown' } }

  describe '.new' do
    before do
      allow(ThinkstCanary.configuration)
        .to receive(:post_query)
        .and_return({ 'canarytoken' => { 'canarytoken' => 'canary_token' } })

      token
    end

    it { expect(ThinkstCanary.configuration).not_to have_received(:post_query) }
  end

  describe '#canary_token' do
    subject { token.canary_token }

    it { is_expected.to eq("Unknown Canary kind 'unknown'") }
  end
end

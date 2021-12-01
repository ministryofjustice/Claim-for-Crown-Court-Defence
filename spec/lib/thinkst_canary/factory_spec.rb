require 'rails_helper'

RSpec.describe ThinkstCanary::Factory do
  subject(:factory) { described_class.new(**factory_options) }

  let(:factory_options) do
    {
      factory_auth: 'factory_auth',
      flock_id: 'flock_id',
      memo: 'Test factory'
    }
  end

  describe '#create_token' do
    subject(:create_token) { factory.create_token(**token_options) }

    let(:token_options) { { memo: 'Another example Canary token', kind: 'http' } }
    let(:token_response) { { 'canarytoken' => { 'canarytoken' => 'canary_token' } } }
    let(:create_params) { token_options.merge(factory_options.slice(:flock_id, :factory_auth)) }

    before { allow(ThinkstCanary.configuration).to receive(:post_query).and_return(token_response) }

    it { is_expected.to be_a ThinkstCanary::Token }
    it { expect(create_token.memo).to eq(token_options[:memo]) }
    it { expect(create_token.kind).to eq(token_options[:kind]) }
    it { expect(create_token.canary_token).to eq(token_response['canarytoken']['canarytoken']) }

    it 'makes a POST request for a token' do
      create_token

      expect(ThinkstCanary.configuration).to have_received(:post_query)
        .with('/api/v1/canarytoken/factory/create', auth: false, params: create_params)
    end
  end
end

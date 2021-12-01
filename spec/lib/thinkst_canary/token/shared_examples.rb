require 'rails_helper'

RSpec.shared_examples 'a Canary token' do |kind|
  describe '.new' do
    subject(:token) { described_class.new(**token_options) }

    let(:canarytoken) { 'canarytoken' }
    let(:token_options) { base_options.merge(extra_token_options) }
    let(:request_options) { base_options.merge(extra_request_options) }

    let(:base_options) do
      {
        kind: kind,
        memo: 'An test Canary token',
        factory_auth: 'factory_auth',
        flock_id: 'flock_id'
      }
    end

    before do
      allow(ThinkstCanary.configuration).to receive(:query)
        .and_return({ 'canarytoken' => { 'canarytoken' => canarytoken } })

      token
    end

    context 'when creating a new token' do
      it do
        expect(ThinkstCanary.configuration)
          .to have_received(:query)
          .with(:post, '/api/v1/canarytoken/factory/create', auth: false, params: request_options)
      end

      it { expect(token.canarytoken).to eq(canarytoken) }
    end

    context 'when using an existing Canary token' do
      let(:existing_canarytoken) { 'existing_canarytoken' }
      let(:token_options) { super().merge(canarytoken: existing_canarytoken) }

      it { expect(ThinkstCanary.configuration).not_to have_received(:query) }
      it { expect(token.canarytoken).to eq(existing_canarytoken) }
    end
  end
end

RSpec.shared_examples 'a Canary token with a file' do
  describe '.download' do
    subject(:token) { described_class.new(**token_options).download }

    let(:token_options) { { canarytoken: 'canarytoken', factory_auth: 'factory_auth' } }
    let(:file_contents) { 'Test file contents' }
    let(:test_file) { Tempfile.new }

    before { allow(ThinkstCanary.configuration).to receive(:query).and_return(test_file) }

    it do
      token

      expect(ThinkstCanary.configuration)
        .to have_received(:query)
        .with(:get, '/api/v1/canarytoken/factory/download', auth: false, json: false, params: token_options)
    end

    it { is_expected.to eq test_file }
  end
end

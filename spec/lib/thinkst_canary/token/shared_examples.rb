require 'rails_helper'

RSpec.shared_examples 'a Canary token with a file' do |kind, file_key|
  describe '.new' do
    subject(:token) { described_class.new(**token_options) }

    let(:token_options) { base_options.merge({ file: StringIO.new }) }
    let(:request_options) { base_options.merge(file_key => file_upload) }
    let(:file_upload) { instance_double(Faraday::UploadIO) }

    let(:base_options) do
      {
        kind:,
        memo: 'An test Canary token',
        factory_auth: 'factory_auth',
        flock_id: 'flock_id'
      }
    end

    context 'when creating a new token' do
      before do
        allow(Faraday::UploadIO).to receive(:new).and_return(file_upload)
        allow(ThinkstCanary.configuration).to receive(:query)
          .and_return({ 'canarytoken' => { 'canarytoken' => 'new-canarytoken' } })

        token
      end

      it do
        expect(ThinkstCanary.configuration)
          .to have_received(:query)
          .with(:post, '/api/v1/canarytoken/factory/create', auth: false, params: request_options)
      end

      it { expect(token.canarytoken).to eq('new-canarytoken') }
    end

    context 'when using an existing Canary token' do
      let(:token_options) { super().merge(canarytoken: 'existing-canarytoken') }

      before do
        allow(ThinkstCanary.configuration).to receive(:query)

        token
      end

      it { expect(ThinkstCanary.configuration).not_to have_received(:query) }
      it { expect(token.canarytoken).to eq('existing-canarytoken') }
    end
  end

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

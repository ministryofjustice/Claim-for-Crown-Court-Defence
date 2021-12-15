require 'rails_helper'

RSpec.shared_examples 'a Canary token' do |kind|
  describe '.new' do
    subject(:token) { described_class.new(**token_options) }

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

    context 'when creating a new token' do
      let(:new_canarytoken) { 'new_canarytoken' }

      before do
        allow(ThinkstCanary.configuration).to receive(:query)
          .and_return({ 'canarytoken' => { 'canarytoken' => new_canarytoken } })

        token
      end

      it do
        expect(ThinkstCanary.configuration)
          .to have_received(:query)
          .with(:post, '/api/v1/canarytoken/factory/create', auth: false, params: request_options)
      end

      it { expect(token.canarytoken).to eq(new_canarytoken) }
    end

    context 'when using an existing Canary token' do
      let(:existing_canarytoken) { 'existing_canarytoken' }
      let(:token_options) { super().merge(canarytoken: existing_canarytoken) }

      before do
        allow(ThinkstCanary.configuration).to receive(:query)

        token
      end

      it { expect(ThinkstCanary.configuration).not_to have_received(:query) }
      it { expect(token.canarytoken).to eq(existing_canarytoken) }
    end
  end
end

RSpec.shared_examples 'a Canary token with a file' do |kind, file_key|
  include_examples 'a Canary token', kind do
    let(:file_upload) { instance_double(Faraday::UploadIO) }
    let(:extra_token_options) { { file: StringIO.new } }
    let(:extra_request_options) { { file_key => file_upload } }

    before { allow(Faraday::UploadIO).to receive(:new).and_return(file_upload) }
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

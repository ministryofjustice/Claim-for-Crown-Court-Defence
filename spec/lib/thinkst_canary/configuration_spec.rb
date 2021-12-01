require 'rails_helper'

RSpec.describe ThinkstCanary::Configuration do
  subject(:configuration) do
    described_class.new.tap do |config|
      config.account_id = config_options[:account_id]
      config.auth_token = config_options[:auth_token]
    end
  end

  let(:config_options) do
    {
      account_id: 'account_id',
      auth_token: 'auth_token'
    }
  end

  describe '#post_query' do
    subject(:post_query) { configuration.post_query(path, **options) }

    let(:path) { 'test/path' }
    let(:response) { { 'test_key' => 'test_value' } }
    let(:options) { {} }
    let(:url) { "https://#{config_options[:account_id]}.canary.tools/#{path}" }

    before { stub_request(:post, url).to_return(body: response.to_json) }

    context 'with no options' do
      it { is_expected.to eq(response) }

      it 'includes the auth token in the request' do
        post_query

        expect(a_request(:post, url).with(body: hash_including(auth_token: config_options[:auth_token])))
          .to have_been_made
      end
    end

    context 'with params' do
      let(:options) { { params: { key: 'value' } } }

      it { is_expected.to eq(response) }

      it 'includes the params with the request' do
        post_query

        expect(
          a_request(:post, url)
            .with(body: hash_including(options[:params].merge(auth_token: config_options[:auth_token])))
        ).to have_been_made
      end
    end

    context 'with `auth: false`' do
      let(:options) { { auth: false } }

      it { is_expected.to eq(response) }

      it 'does not include the auth token' do
        post_query

        expect(a_request(:post, url).with(body: hash_including(auth_token: config_options[:auth_token])))
          .not_to have_been_made
      end
    end

    context 'with a 4xx client error response' do
      before { stub_request(:post, url).to_return(status: 404) }

      it { expect { post_query }.to raise_error(ThinkstCanary::HttpError, 'HTTP status 404') }
    end

    context 'with a 5xx server error response' do
      before { stub_request(:post, url).to_return(status: 500) }

      it { expect { post_query }.to raise_error(ThinkstCanary::HttpError, 'HTTP status 500') }
    end
  end
end

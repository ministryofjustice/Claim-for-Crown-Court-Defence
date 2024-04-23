require 'rails_helper'

describe Remote::HttpClient do
  subject(:client) { described_class.instance }

  describe '#base_url' do
    context 'when base_url is specified in configure clause' do
      before { described_class.configure { |client| client.base_url = 'my_base_url' } }

      it 'uses the base url suppllied in the configure clause' do
        expect(client.base_url).to eq 'my_base_url'
      end
    end

    context 'when base_url _NOT_ specified in configure block' do
      before do
        described_class.configure { |c| c.base_url = nil }
        allow(Settings).to receive(:remote_api_url).and_return('default_base_url')
      end

      it 'uses the base url from Settings' do
        expect(client.base_url).to eq 'default_base_url'
      end
    end
  end

  describe '#get' do
    let(:api_url)  { 'https://my_api_url' }
    let(:api_key)  { 'my_key' }
    let(:path)     { 'my_path' }
    let(:query)    { { 'key' => 'value' } }
    let(:cache_key) { "#{path}?api_key=#{api_key}&key=value" }

    before do
      described_class.configure do |client|
        client.base_url = api_url
        client.api_key = api_key
        client.logger = Rails.logger
        client.open_timeout = 2
        client.timeout = 4
      end

      allow(Caching::APIRequest).to receive(:cache).with(cache_key).and_call_original
      allow(JSON).to receive(:parse).with('body', symbolize_names: true).and_return({ key: 'value' })
      stub_request(:get, "#{api_url}/#{cache_key}")
        .with(headers: { 'X-Forwarded-Proto': 'https', 'X-Forwarded-Ssl': 'on' })
        .to_return(status: 200, body: 'body')
    end

    it 'makes request to the correct endpoint' do
      expect(client.get(path, **query)).to eq({ key: 'value' })
    end
  end
end

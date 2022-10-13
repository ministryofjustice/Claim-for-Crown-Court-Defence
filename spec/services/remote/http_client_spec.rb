require 'rails_helper'

module Remote
  describe Remote::HttpClient do
    describe '.current' do
      context 'when self.instance already exists' do
        it 'returns the instance' do
          client = described_class.current
          expect(client).to be_instance_of(described_class)
        end
      end

      context 'when self.instance does not already exist' do
        it 'calls new and returns the new instance' do
          client = described_class.current
          expect(described_class.current).to eq client
        end
      end
    end

    describe 'base_url' do
      context 'when base_url is specified in configure clause' do
        before { described_class.configure { |client| client.base_url = 'my_base_url' } }

        it 'uses the base url suppllied in the configure clause' do
          expect(described_class.base_url).to eq 'my_base_url'
        end
      end

      context 'when base_url _NOT_ specified in configure block' do
        before do
          described_class.configure { |c| c.base_url = nil }
          allow(Settings).to receive(:remote_api_url).and_return('default_base_url')
        end

        it 'uses the base url from Settings' do
          expect(described_class.base_url).to eq 'default_base_url'
        end
      end
    end

    describe '.get' do
      subject(:result) { described_class.current.get(path, **query) }

      let(:api_url)  { 'my_api_url' }
      let(:api_key)  { 'my_key' }
      let(:path)     { 'my_path' }
      let(:query)    { { 'key' => 'value' } }
      let(:endpoint) { 'my_api_url/my_path?api_key=my_key&key=value' }

      before do
        described_class.configure do |client|
          client.base_url = api_url
          client.api_key = api_key
          client.logger = Rails.logger
          client.open_timeout = 2
          client.timeout = 4
        end
      end

      it 'calls execute on RestClient::Request' do
        response = instance_double(Net::HTTPResponse, body: 'body', header: {})
        allow(JSON).to receive(:parse).with('body', symbolize_names: true).and_return({ key: 'value' })
        allow(RestClient::Request).to receive(:execute).with(method: :get, url: endpoint, timeout: 4,
                                                             open_timeout: 2).and_return(response.body)

        expect(result).to eq({ key: 'value' })
      end
    end
  end
end

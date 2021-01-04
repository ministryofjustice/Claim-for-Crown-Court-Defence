require 'rails_helper'

module Remote

  describe HttpClient do
    describe '.current' do
      context 'self.instance already exists' do
        it 'returns the instance' do
          client = HttpClient.current
          expect(client).to be_instance_of(HttpClient)
        end
      end

      context 'self.instance does not already exist' do
        it 'calls new and returns the new instance' do
          client = HttpClient.current
          expect(HttpClient.current).to eq client
        end
      end
    end

    describe 'base_url' do
      context 'base_url is specified in configure clause' do
        it 'uses the base url suppllied in the configure clause' do
          HttpClient.configure { |client| client.base_url = 'my_base_url' }
          expect(HttpClient.base_url).to eq 'my_base_url'
        end
      end

      context 'base_url _NOT_ specified in configure bloack' do
        it 'uses the base url from Settings' do
          HttpClient.configure { |c| c.base_url = nil }
          expect(Settings).to receive(:remote_api_url).and_return('default_base_url')
          expect(HttpClient.base_url).to eq 'default_base_url'
        end
      end
    end

    describe '.get' do
      let(:api_url)  { 'my_api_url' }
      let(:api_key)  { 'my_key' }
      let(:path)     { 'my_path' }
      let(:query)    { { 'key' => 'value' } }
      let(:endpoint) { 'my_api_url/my_path?api_key=my_key&key=value' }

      before(:each) do
        HttpClient.configure do |client|
          client.base_url = api_url
          client.api_key = api_key
          client.logger = Rails.logger
          client.open_timeout = 2
          client.timeout = 4
        end
      end

      it 'calls execute on RestClient::Request' do
        response = double('HTTPResponse', body: 'body', headers: {})
        expect(Caching::ApiRequest).to receive(:cache).with(endpoint).and_call_original
        expect(JSON).to receive(:parse).with('body', symbolize_names: true).and_return({ key: 'value' })
        expect(RestClient::Request).to receive(:execute).with(method: :get, url: endpoint, timeout: 4, open_timeout: 2).and_return(response)

        result = HttpClient.current.get(path, query)

        expect(result).to eq({ key: 'value' })
      end
    end
  end
end

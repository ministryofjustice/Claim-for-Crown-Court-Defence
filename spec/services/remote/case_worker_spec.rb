require 'rails_helper'

module Remote
  describe Remote::CaseWorker do
    describe '.resource_path' do
      it 'returns case_wokers' do
        expect(described_class.resource_path).to eq 'case_workers'
      end
    end
  end

  describe '.all' do
    let(:user) { double Remote::User, api_key: 'my_api_key' }
    let(:query) { { 'query_key' => 'query value'} }
    let(:case_worker_collection) { double 'CaseWorker Collection', map: 'mapped_collection' }

    it 'calls HttpClient to make the query' do
      client = double Remote::HttpClient
      expect(Remote::HttpClient).to receive(:current).and_return(client)
      expect(client).to receive(:get).with('case_workers', 'query_key' => 'query value', api_key: 'my_api_key').and_return(case_worker_collection)
      expect(::Remote::CaseWorker.all(user, query)).to eq('mapped_collection')
    end
  end
end

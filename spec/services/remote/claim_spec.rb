require 'rails_helper'

module Remote
  describe Claim do

    let(:user) { double ::Remote::User }
    let(:query) { { 'my_query_key' => 'my query value' } }

    describe '.resource_path' do
      it 'returns resource path' do
        expect(::Remote::Claim.resource_path).to eq 'case_workers/claims'
      end
    end

    describe '.user_allocations' do
      it 'calls all by status' do
        expect(::Remote::Claim).to receive(:all_by_status).with('current', user: user, query: query)
        ::Remote::Claim.user_allocations(user, query)
      end
    end

    describe '.allocated' do
      it 'calls all by status' do
        expect(::Remote::Claim).to receive(:all_by_status).with('allocated', user: user, query: query)
        ::Remote::Claim.allocated(user, query)
      end
    end

    describe '.unallocated' do
      it 'calls all by status' do
        expect(::Remote::Claim).to receive(:all_by_status).with('unallocated', user: user, query: query)
        ::Remote::Claim.unallocated(user, query)
      end
    end

    describe '.archived' do
      it 'calls all by status' do
        expect(::Remote::Claim).to receive(:all_by_status).with('archived', user: user, query: query)
        ::Remote::Claim.archived(user, query)
      end
    end

    describe 'all_by_status'do
      let(:claim_collection) { double 'Claim Collection', map: 'mapped_collection' }
      let(:user) { double Remote::User, api_key: 'my_api_key' }
      let(:query_params) do
        {
          'my_query_key' => 'my query value',
          api_key: 'my_api_key',
          status: 'current'
        }
      end

      it 'calls HttpClient to make the query' do
        client = double Remote::HttpClient
        expect(Remote::HttpClient).to receive(:current).and_return(client)
        expect(client).to receive(:get).with('case_workers/claims', query_params).and_return(claim_collection)
        expect(::Remote::Claim.__send__(:all_by_status, 'current', user: user , query: query)).to eq('mapped_collection')
      end
    end
  end
end
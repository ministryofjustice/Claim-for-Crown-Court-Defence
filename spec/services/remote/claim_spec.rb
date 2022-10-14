require 'rails_helper'

module Remote
  describe Claim do
    let(:user) { instance_double ::Remote::User }
    let(:query) { { 'my_query_key' => 'my query value' } }

    describe '.resource_path' do
      it 'returns resource path' do
        expect(::Remote::Claim.resource_path).to eq 'case_workers/claims'
      end
    end

    describe '.user_allocations' do
      before { allow(::Remote::Claim).to receive(:all_by_status).with('current', user:, query:) }

      it 'calls all by status' do
        ::Remote::Claim.user_allocations(user, **query)
        expect(::Remote::Claim).to have_received(:all_by_status).with('current', user:, query:)
      end
    end

    describe '.allocated' do
      before { allow(::Remote::Claim).to receive(:all_by_status).with('allocated', user:, query:) }

      it 'calls all by status' do
        ::Remote::Claim.allocated(user, **query)
        expect(::Remote::Claim).to have_received(:all_by_status).with('allocated', user:, query:)
      end
    end

    describe '.unallocated' do
      before { allow(::Remote::Claim).to receive(:all_by_status).with('unallocated', user:, query:) }

      it 'calls all by status' do
        ::Remote::Claim.unallocated(user, **query)
        expect(::Remote::Claim).to have_received(:all_by_status).with('unallocated', user:, query:)
      end
    end

    describe '.archived' do
      before { allow(::Remote::Claim).to receive(:all_by_status).with('archived', user:, query:) }

      it 'calls all by status' do
        ::Remote::Claim.archived(user, **query)
        expect(::Remote::Claim).to have_received(:all_by_status).with('archived', user:, query:)
      end
    end

    describe '.all_by_status' do
      let(:claim_collection) { double 'Claim Collection', map: 'mapped_collection' }
      let(:user) { double Remote::User, api_key: 'my_api_key' }
      let(:query_params) do
        {
          'my_query_key' => 'my query value',
          api_key: 'my_api_key',
          status: 'current'
        }
      end

      before do
        client = double Remote::HttpClient
        allow(Remote::HttpClient).to receive(:instance).and_return(client)
        allow(client).to receive(:get).with('case_workers/claims', **query_params).and_return(claim_collection)
      end

      it 'calls HttpClient to make the query' do
        expect(::Remote::Claim.__send__(:all_by_status, 'current', user:, query:)).to eq('mapped_collection')
      end
    end
  end
end

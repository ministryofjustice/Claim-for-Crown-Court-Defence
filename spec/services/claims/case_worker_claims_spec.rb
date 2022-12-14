require 'rails_helper'

module Claims
  describe CaseWorkerClaims do
    let(:user) { create(:user) }

    let(:criteria) do
      {
        sorting: 'last_submitted_at',
        direction: 'asc',
        scheme: 'agfs',
        filter: 'all',
        page: 0,
        limit: 25,
        search: nil,
        value_band_id: 0
      }
    end

    describe '#claims' do
      subject(:claims) { described_class.new(current_user: user, action:, criteria:).claims }

      let(:method) { action.to_sym }

      before do
        allow(Remote::Claim).to receive(method)
      end

      context 'with current action' do
        let(:action) { 'current' }
        let(:method) { :user_allocations }

        it 'calls user_allocations on Remote::Claim' do
          claims
          expect(Remote::Claim).to have_received(method).with(user, **criteria)
        end
      end

      context 'with archived action' do
        let(:action) { 'archived' }

        it 'calls archived on Remote::Claim' do
          claims
          expect(Remote::Claim).to have_received(method).with(user, **criteria)
        end
      end

      context 'with allocated action' do
        let(:action) { 'allocated' }

        it 'calls allocated on Remote::Claim' do
          claims
          expect(Remote::Claim).to have_received(method).with(user, **criteria)
        end
      end

      context 'with unallocated action' do
        let(:action) { 'unallocated' }

        it 'calls unallocated on Remote::Claim' do
          claims
          expect(Remote::Claim).to have_received(method).with(user, **criteria)
        end
      end

      context 'with unrecognised action' do
        let(:action) { 'no-such-action' }
        let(:method) { :user_allocations }

        it 'raises' do
          expect { claims }.to raise_error ArgumentError, 'Unknown action: no-such-action'
        end
      end
    end
  end
end

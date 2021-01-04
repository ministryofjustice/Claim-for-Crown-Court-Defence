require 'rails_helper'

module Claims
  describe CaseWorkerClaims do
    let(:user) { create :user }

    let(:criteria) do
      {
        :sorting => 'last_submitted_at',
        :direction => 'asc',
        :scheme => 'agfs',
        :filter => 'all',
        :page => 0,
        :limit => 25,
        :search => nil,
        :value_band_id => 0
      }
    end

    context 'Using remote' do
      # before(:each) { allow(Settings).to receive(:case_workers_remote_allocations?).and_return(true) }

      context 'action current' do
        it 'calls user_allocations on Remote::Claim' do
          expect(Remote::Claim).to receive(:user_allocations).with(user, criteria)
          CaseWorkerClaims.new(current_user: user, action: 'current', criteria: criteria).claims
        end
      end

      context 'archived' do
        it 'calls archived on Remote::Claim' do
          expect(Remote::Claim).to receive(:archived).with(user, criteria)
          CaseWorkerClaims.new(current_user: user, action: 'archived', criteria: criteria).claims
        end
      end

      context 'allocated' do
        it 'calls allocated on Remote::Claim' do
          expect(Remote::Claim).to receive(:allocated).with(user, criteria)
          CaseWorkerClaims.new(current_user: user, action: 'allocated', criteria: criteria).claims
        end
      end

      context 'unallocated' do
        it 'calls unallocated on Remote::Claim' do
          expect(Remote::Claim).to receive(:unallocated).with(user, criteria)
          CaseWorkerClaims.new(current_user: user, action: 'unallocated', criteria: criteria).claims
        end
      end

      context 'unrecognised action' do
        it 'raises' do
          expect {
            CaseWorkerClaims.new(current_user: user, action: 'no-such-action', criteria: criteria).claims
          }.to raise_error ArgumentError, 'Unknown action: no-such-action'
        end
      end
    end
  end
end

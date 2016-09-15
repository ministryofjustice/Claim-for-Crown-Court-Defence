require 'rails_helper'

RSpec.describe ClaimStateTransitionPresenter do

  let(:claim) { create(:allocated_claim) }
  let(:current_user) { create(:user, first_name: 'Brielle', last_name: 'Jenkins') }
  let(:another_user) { create(:user, first_name: 'Madyson', last_name: 'Gibson') }

  let(:subject) { ClaimStateTransitionPresenter.new(claim.last_state_transition, view) }

  describe '#transition_message' do
    before(:each) do
      allow(subject).to receive(:current_user_persona).and_return('CaseWorker')
    end

    it 'returns a human readable string describing a state change' do
      expect(subject.transition_message).to eq "Claim allocated"
    end
  end

  describe '#audit_users' do
    let(:is_external_user) { false }

    before(:each) do
      allow(view).to receive(:current_user_is_external_user?).and_return(is_external_user)
    end

    context 'without an author user' do
      it 'returns a default string' do
        expect(subject.audit_users).to eq('(System)')
      end
    end

    context 'with an author user when logged in as an external user' do
      let(:is_external_user) { true }
      let(:claim) { create(:rejected_claim) }

      before(:each) do
        allow(view).to receive(:current_user).and_return(current_user)
      end

      context 'and the transition was triggered by the same user' do
        before(:each) do
          claim.archive_pending_delete!(author_id: current_user.id)
        end

        it 'returns a default string' do
          expect(subject.audit_users).to eq('Brielle Jenkins')
        end
      end

      context 'and the transition was triggered by a different user' do
        before(:each) do
          claim.archive_pending_delete!(author_id: another_user.id)
        end

        it 'returns a default string' do
          expect(subject.audit_users).to eq('(System)')
        end
      end
    end

    context 'with an author user but without a subject user' do
      let(:claim) { create(:rejected_claim) }

      before(:each) do
        claim.archive_pending_delete!(author_id: current_user.id)
      end

      it 'returns a human readable string describing who did the change' do
        expect(claim.last_state_transition.event).to eq('archive_pending_delete')
        expect(subject.audit_users).to eq('Brielle Jenkins')
      end
    end

    context 'with a subject user' do
      let(:claim) { create(:submitted_claim) }

      before(:each) do
        claim.allocate!(author_id: current_user.id, subject_id: another_user.id)
      end

      it 'returns a human readable string describing who did the change and to whom' do
        expect(claim.last_state_transition.event).to eq('allocate')
        expect(subject.audit_users).to eq('Brielle Jenkins to Madyson Gibson')
      end
    end
  end
end
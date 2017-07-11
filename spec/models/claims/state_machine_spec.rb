require 'rails_helper'

RSpec.describe Claims::StateMachine, type: :model do
  subject { create(:claim) }

  describe 'all available states' do
    let(:states) do
      [
        :allocated,
        :archived_pending_delete,
        :awaiting_written_reasons,
        :deleted,
        :draft,
        :authorised,
        :part_authorised,
        :refused,
        :rejected,
        :redetermination,
        :submitted,
        :deallocated
      ]
    end

    it('exist') { expect(Claim::BaseClaim.active.state_machine.states.map(&:name).sort).to eq(states.sort) }
  end

  describe 'NON_VALIDATION_STATES' do
    subject { Claims::StateMachine::NON_VALIDATION_STATES }

    let(:states) { Claim::BaseClaim.active.state_machine.states.map(&:name).sort }
    it { is_expected.to eql (states - [:draft, :submitted]).map(&:to_s) }
  end

  describe 'valid transitions' do
    describe 'from redetermination' do
      before { subject.submit! }

      it { expect{ subject.allocate! }.to change{ subject.state }.to('allocated') }
    end

    describe 'from awaiting_written_reasons' do
      before { subject.submit! }

      it { expect{ subject.allocate! }.to change{ subject.state }.to('allocated') }
    end

    describe 'from allocated' do
      before do
        subject.submit!
        subject.allocate!
      end

      it { expect{ subject.reject! }.to      change{ subject.state }.to('rejected') }
      it { expect{ subject.submit! }.to      change{ subject.state }.to('submitted') }
      it { expect{ subject.refuse! }.to      change{ subject.state }.to('refused') }

      it {
        expect{
          subject.assessment.update(fees: 100.00, expenses: 23.45)
          subject.authorise_part!
        }.to change{ subject.state }.to('part_authorised') }

      it { expect{
        subject.assessment.update(fees: 100.00, expenses: 23.45)
        subject.authorise!
      }.to change{ subject.state }.to('authorised') }

      it { expect{ subject.archive_pending_delete! }.to raise_error }

      it 'should be able to deallocate' do
        expect{
          subject.deallocate!
        }.to change{ subject.state }.to('submitted')
      end

      it 'should unlink case workers on deallocate' do
        expect(subject.case_workers).to receive(:destroy_all)
        subject.deallocate!
      end
    end

    describe 'from draft' do
      it { expect{ subject.submit! }.to change{ subject.state }.to('submitted') }
      it { expect{ subject.archive_pending_delete! }.to raise_error }
    end

    describe 'from authorised' do
      before {
        subject.submit!
        subject.allocate!
        subject.assessment.update(fees: 100.00, expenses: 23.45)
        subject.authorise!
      }

      it { expect{ subject.redetermine! }.to change{ subject.state }.to('redetermination') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from part_authorised' do
      before {
        subject.submit!
        subject.allocate!
        subject.assessment.update(fees: 100.00, expenses: 23.45)
        subject.authorise_part!
      }

      it { expect{ subject.redetermine! }.to change{ subject.state }.to('redetermination') }

      it { expect{ subject.await_written_reasons! }.to change{ subject.state }.to('awaiting_written_reasons') }

      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from refused' do
      before { subject.submit!; subject.allocate!; subject.refuse! }

      it { expect{ subject.redetermine! }.to change{ subject.state }.to('redetermination') }

      it { expect{ subject.await_written_reasons! }.to change{ subject.state }.to('awaiting_written_reasons') }

      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from rejected' do
      before { subject.submit!; subject.allocate!; subject.reject! }

      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }

    end

    describe 'from submitted' do
      before { subject.submit! }

      it { expect{ subject.allocate! }.to change{ subject.state }.to('allocated') }

      it { expect{ subject.archive_pending_delete! }.to raise_error }
    end

    describe "Allocated claim" do
      let(:claim) { create(:allocated_claim) }

      it "has a blank assessment" do
        expect(claim.assessment).not_to eq(nil)
        expect(claim.assessment.fees).to eq(0)
        expect(claim.assessment.expenses).to eq(0)
        expect(claim.assessment.disbursements).to eq(0)
      end

      context "updating assessment" do
        context "without updating the status" do
          let(:params) do
            {
              "assessment_attributes" => {
                "fees" => "1.00",
                "expenses" => "0.00",
                "vat_amount" => "0.00",
                "id" => claim.assessment.id
              }
            }
          end

          it "does not update the assessment" do
            claim.update_model_and_transition_state(params) rescue nil
            expect(claim.reload.assessment.fees).to eq(0)
          end
        end
      end
    end

    describe 'when supplier number has been invalidated' do
      let(:claim) { create :litigator_claim, :fixed_fee, force_validation: true }

      before { SupplierNumber.find_by(supplier_number: claim.supplier_number).delete }

      it { expect{ claim.submit! }.not_to raise_error }
    end
  end # describe 'valid transitions'

  describe 'set triggers' do
    before { Timecop.freeze(Time.now) }
    after  { Timecop.return }

    describe 'make archive_pending_delete valid for 180 days' do
      subject { create(:authorised_claim) }

      it {
        frozen_time = Time.now
        Timecop.freeze(frozen_time) { subject.archive_pending_delete! }

        expect(subject.valid_until).to eq(frozen_time + 180.days)
      }
    end

    describe 'make last_submitted_at attribute equal now' do
      it 'sets the last_submitted_at to the current time' do
        current_time = Time.now
        subject.submit!
        expect(subject.last_submitted_at).to eq(current_time)
      end

      it 'sets the original_submission_date to the current time' do
        current_time = Time.now
        subject.submit!
        expect(subject.original_submission_date).to eq(current_time)
      end
    end

    describe 'update last_submitted_at on redetermination or await_written_reasons' do
      it 'set the last_submitted_at to the current time for redetermination' do
        current_time = Time.now
        subject.submit!
        subject.allocate!
        subject.refuse!

        Timecop.freeze 6.months.from_now do
          subject.redetermine!
          expect(subject.last_submitted_at).to eq(current_time + 6.months)
        end
      end

      it 'set the last_submitted_at to the current time for awaiting_written_reasons' do
        current_time = Time.now
        subject.submit!
        subject.allocate!
        subject.refuse!

        Timecop.freeze 6.months.from_now do
          subject.await_written_reasons!
          expect(subject.last_submitted_at).to eq(current_time + 6.months)
        end
      end
    end

    describe 'authorise! makes authorised_at attribute equal now' do
      before { subject.submit!; subject.allocate! }

      it {
        subject.assessment.update(fees: 100.00, expenses: 23.45)

        frozen_time = Time.now + 1.month
        Timecop.freeze(frozen_time) { subject.authorise! }

        expect(subject.authorised_at).to eq(frozen_time)
      }
    end

    describe 'authorise_part! makes authorised_at attribute equal now' do
      before { subject.submit!; subject.allocate! }

      it {
        subject.assessment.update(fees: 100.00, expenses: 23.45)

        frozen_time = Time.now + 1.month
        Timecop.freeze(frozen_time) { subject.authorise_part! }

        expect(subject.authorised_at).to eq(frozen_time)
      }
    end
  end # describe 'set triggers'

  describe '.is_in_state?' do
    let(:claim)         { build :unpersisted_claim }

    it 'should be true if state is in EXTERNAL_USER_DASHBOARD_SUBMITTED_STATES' do
      allow(claim).to receive(:state).and_return('allocated')
      expect(Claims::StateMachine.is_in_state?(:external_user_dashboard_submitted?, claim)).to be true
    end

    it 'should return false if the state is not one of the EXTERNAL_USER_DASHBOARD_SUBMITTED_STATES' do
      allow(claim).to receive(:state).and_return('draft')
      expect(Claims::StateMachine.is_in_state?(:external_user_dashboard_submitted?, claim)).to be false
    end

    it 'should return false if the method name is not recognised' do
      allow(claim).to receive(:state).and_return('draft')
      expect(Claims::StateMachine.is_in_state?(:external_user_rubbish_submitted?, claim)).to be false
    end
  end

  describe 'state transition audit trail' do
    let!(:claim) { create(:claim) }
    let!(:expected) do
      {
        event: 'submit',
        from: 'draft',
        to: 'submitted',
        reason_code: nil
      }
    end

    it 'should log state transitions' do
      expect { claim.submit! }.to change(ClaimStateTransition, :count).by(1)
    end

    it 'the log transition should reflect the state transition/change' do
      claim.submit!
      expect(ClaimStateTransition.last.event).to eq(expected[:event])
      expect(ClaimStateTransition.last.from).to eq(expected[:from])
      expect(ClaimStateTransition.last.to).to eq(expected[:to])
      expect(ClaimStateTransition.last.reason_code).to eq(expected[:reason_code])
    end
  end

  describe 'before submit state transition' do
    it 'sets the allocation_type for trasfer_claims' do
      claim = build :transfer_claim
      expect(claim.allocation_type).to be nil
      claim.submit!
      expect(claim.allocation_type).to eq 'Grad'
    end
  end

  describe 'reject! supports a reason code' do
    before { subject.submit!; subject.allocate!; subject.reject!(reason_code: reason_code) }

    let(:reason_code) { 'reason' }

    it 'updates the transition reason code' do
      transition = subject.claim_state_transitions.first
      expect(transition.to).to eq('rejected')
      expect(transition.reason_code).to eq(reason_code)
    end
  end

  describe 'refuse! supports a reason code' do
    before { subject.submit!; subject.allocate!; subject.refuse!(reason_code: reason_code) }

    let(:reason_code) { 'reason' }

    it 'updates the transition reason code' do
      transition = subject.claim_state_transitions.first
      expect(transition.to).to eq('refused')
      expect(transition.reason_code).to eq(reason_code)
    end
  end

  describe '.set_allocation_type' do
    it 'calls the class method' do
      claim = build :transfer_claim
      claim.__send__(:set_allocation_type)
    end
  end
end

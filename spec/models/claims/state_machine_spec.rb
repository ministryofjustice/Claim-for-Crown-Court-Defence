require 'rails_helper'

RSpec.describe Claims::StateMachine, type: :model do
  subject(:claim) { create(:advocate_claim) }

  context 'state machine' do
    let(:states) do
      [
        :allocated,
        :archived_pending_delete,
        :archived_pending_review,
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

    it 'has expected states' do
      expect(Claim::BaseClaim.active.state_machine.states.map(&:name).sort).to eq(states.sort)
    end
  end

  describe 'NON_VALIDATION_STATES' do
    subject { Claims::StateMachine::NON_VALIDATION_STATES }

    let(:states) { Claim::BaseClaim.active.state_machine.states.map(&:name).sort }
    it { is_expected.to eql (states - [:draft, :submitted]).map(&:to_s) }
  end

  describe '#around_transition' do
    let(:claim) { create(:submitted_claim) }
    let(:assessment) { create(:assessment) }
    let(:case_type) { create(:case_type, :cbr) }

    context 'sets flag to disable all validations' do
      TRANSITION_EVENT_CHAINS = {
        allocate: %i[allocate!],
        archive_pending_delete: %i[allocate! refuse! archive_pending_delete!],
        await_written_reasons: %i[allocate! refuse! await_written_reasons!],
        deallocate: %i[allocate! deallocate!],
        redetermine: %i[allocate! reject! redetermine!],
        refuse: %i[allocate! refuse!],
        reject: %i[allocate! reject!]
      }

      TRANSITION_EVENT_CHAINS.each do |transition, events|
        context "when transitioning via event chain #{events}" do
          before do
            *precursor_events, _event = events
            precursor_events.each { |event| claim.send(event) }
          end

          it "##{events.last}" do
            expect(claim).to receive(:disable_for_state_transition=).with(:all).exactly(1).times
            expect(claim).to receive(:disable_for_state_transition=).with(nil).exactly(1).times
            claim.send(events.last)
          end
        end
      end
    end

    context 'sets flag to enable only assessment validations' do
      before do
        claim.allocate!
        claim.assessment.update!(fees: 100.00)
      end

      %i[authorise! authorise_part!].each do |transition|
        it "when transitioning via ##{transition}" do
          expect(claim).to receive(:disable_for_state_transition=).with(:only_amount_assessed).exactly(1).times
          expect(claim).to receive(:disable_for_state_transition=).with(nil).exactly(1).times
          claim.send(transition)
        end
      end
    end
  end

  describe 'valid transitions' do
    context 'from redetermination' do
      before { claim.submit! }

      it { expect { claim.allocate! }.to change { claim.state }.to('allocated') }
    end

    context 'from awaiting_written_reasons' do
      before { claim.submit! }

      it { expect { claim.allocate! }.to change { claim.state }.to('allocated') }
    end

    context 'from allocated' do
      before do
        claim.submit!
        claim.allocate!
      end

      it { expect { claim.reject! }.to change { claim.state }.to('rejected') }
      it { expect { claim.submit! }.to change { claim.state }.to('submitted') }
      it { expect { claim.refuse! }.to change { claim.state }.to('refused') }

      context 'with an assessed amount' do
        before { claim.assessment.update(fees: 100.00, expenses: 23.45) }

        it { expect { claim.authorise_part! }.to change { claim.state }.to('part_authorised') }
        it { expect { claim.authorise! }.to change { claim.state }.to('authorised') }
      end

      it { expect { claim.archive_pending_delete! }.to raise_error(StateMachines::InvalidTransition) }

      it 'should be able to deallocate' do
        expect { claim.deallocate! }.to change { claim.state }.to('submitted')
      end

      it 'should unlink case workers on deallocate' do
        expect(claim.case_workers).to receive(:destroy_all)
        claim.deallocate!
      end

      context 'when a claim exists with a, legacy, now non-valid evidence provision fee' do
        let(:claim) { create(:litigator_claim) }
        let(:fee) { build :misc_fee, claim: claim, amount: '123', fee_type: fee_type }
        let(:fee_type) { build :misc_fee_type, :mievi }

        describe 'de-allocation' do
          it { expect { claim.deallocate! }.not_to raise_error }
        end

        describe 'part-authorising' do
          it {
            expect {
              claim.assessment.update(fees: 100.00, expenses: 23.45)
              claim.authorise_part!
            }.to change { claim.state }.to('part_authorised')
          }
        end
      end
    end

    context 'from draft' do
      it { expect { claim.submit! }.to change { claim.state }.to('submitted') }
      it { expect { claim.archive_pending_delete! }.to raise_error(StateMachines::InvalidTransition) }
    end

    context 'from authorised' do
      before {
        claim.submit!
        claim.allocate!
        claim.assessment.update(fees: 100.00, expenses: 23.45)
        claim.authorise!
      }

      it { expect { claim.redetermine! }.to change { claim.state }.to('redetermination') }
      it { expect { claim.archive_pending_delete! }.to change { claim.state }.to('archived_pending_delete') }
      it { expect { claim.archive_pending_review! }.to raise_error(StateMachines::InvalidTransition) }

      context 'when it is a hardship claim' do
        subject(:claim) { create(:advocate_hardship_claim) }

        it { expect { claim.archive_pending_review! }.to change { claim.state }.to('archived_pending_review') }
        it { expect { claim.archive_pending_delete! }.to raise_error(StateMachines::InvalidTransition) }

        context 'that has been archived_pending_review' do
          subject(:claim) { create(:advocate_hardship_claim) }

          before { claim.archive_pending_review! }

          it { expect(claim.state).to eq 'archived_pending_review' }
          it { expect { claim.archive_pending_delete! }.to change { claim.state }.to('archived_pending_delete') }
        end
      end
    end

    context 'from part_authorised' do
      before {
        claim.submit!
        claim.allocate!
        claim.assessment.update(fees: 100.00, expenses: 23.45)
        claim.authorise_part!
      }

      it { expect { claim.redetermine! }.to change { claim.state }.to('redetermination') }
      it { expect { claim.await_written_reasons! }.to change { claim.state }.to('awaiting_written_reasons') }
      it { expect { claim.archive_pending_delete! }.to change { claim.state }.to('archived_pending_delete') }
    end

    context 'from refused' do
      before { claim.submit!; claim.allocate!; claim.refuse! }

      it { expect { claim.redetermine! }.to change { claim.state }.to('redetermination') }
      it { expect { claim.await_written_reasons! }.to change { claim.state }.to('awaiting_written_reasons') }
      it { expect { claim.archive_pending_delete! }.to change { claim.state }.to('archived_pending_delete') }
    end

    context 'from rejected' do
      before { claim.submit!; claim.allocate!; claim.reject! }

      it { expect { claim.archive_pending_delete! }.to change { claim.state }.to('archived_pending_delete') }
    end

    context 'from submitted' do
      before { claim.submit! }

      it { expect { claim.allocate! }.to change { claim.state }.to('allocated') }
      it { expect { claim.archive_pending_delete! }.to raise_error(StateMachines::InvalidTransition) }

      context 'when a claim exists with a, legacy, now non-valid evidence provision fee' do
        let(:claim) { create :litigator_claim }
        let(:fee) { build :misc_fee, claim: claim, amount: '123', fee_type: fee_type }
        let(:fee_type) { build :misc_fee_type, :mievi }

        it { expect { claim.allocate! }.not_to raise_error }
      end
    end

    context 'Allocated claim' do
      let(:claim) { create(:allocated_claim) }

      it 'has a blank assessment' do
        expect(claim.assessment).not_to eq(nil)
        expect(claim.assessment.fees).to eq(0)
        expect(claim.assessment.expenses).to eq(0)
        expect(claim.assessment.disbursements).to eq(0)
      end

      context 'updating assessment' do
        context 'without updating the status' do
          let(:params) do
            {
              'assessment_attributes' => {
                'fees' => '1.00',
                'expenses' => '0.00',
                'vat_amount' => '0.00',
                'id' => claim.assessment.id
              }
            }
          end

          it 'does not update the assessment' do
            claim.update_model_and_transition_state(params) rescue nil
            expect(claim.reload.assessment.fees).to eq(0)
          end
        end
      end
    end

    context 'when supplier number has been invalidated' do
      let(:claim) { create(:litigator_claim, :fixed_fee, force_validation: true, fixed_fee: build(:fixed_fee, :lgfs)) }

      before { SupplierNumber.find_by(supplier_number: claim.supplier_number).delete }

      it { expect { claim.submit! }.not_to raise_error }
    end
  end

  context 'set triggers' do
    context 'make archive_pending_delete valid for 180 days' do
      subject(:claim) { create(:authorised_claim) }
      let(:frozen_time) { Time.now.change(usec: 0) }

      before do
        travel_to(frozen_time) { claim.archive_pending_delete! }
      end

      it {
        expect(claim.valid_until).to eq(frozen_time + 180.days)
      }
    end

    context 'make last_submitted_at attribute equal now' do
      before { freeze_time }
      after  { travel_back }

      it 'sets the last_submitted_at to the current time' do
        current_time = Time.now
        claim.submit!
        expect(claim.last_submitted_at).to eq(current_time)
      end

      it 'sets the original_submission_date to the current time' do
        current_time = Time.now
        claim.submit!
        expect(claim.original_submission_date).to eq(current_time)
      end
    end

    context 'update last_submitted_at on redetermination or await_written_reasons' do
      it 'set the last_submitted_at to the current time for redetermination' do
        current_time = Time.now.change(usec: 0)
        claim.submit!
        claim.allocate!
        claim.refuse!

        travel_to current_time + 6.months do
          claim.redetermine!
          expect(claim.last_submitted_at).to eq(current_time + 6.months)
        end
      end

      it 'set the last_submitted_at to the current time for awaiting_written_reasons' do
        current_time = Time.now.change(usec: 0)
        claim.submit!
        claim.allocate!
        claim.refuse!

        travel_to(current_time + 6.months) do
          claim.await_written_reasons!
          expect(claim.last_submitted_at).to eq(current_time + 6.months)
        end
      end
    end

    describe 'authorise! makes authorised_at attribute equal now' do
      before { claim.submit!; claim.allocate! }

      it {
        claim.assessment.update(fees: 100.00, expenses: 23.45)

        frozen_time = Time.now.change(usec: 0) + 1.month
        travel_to(frozen_time) { claim.authorise! }

        expect(claim.authorised_at).to eq(frozen_time)
      }
    end

    describe 'authorise_part! makes authorised_at attribute equal now' do
      before { claim.submit!; claim.allocate! }

      it {
        claim.assessment.update(fees: 100.00, expenses: 23.45)

        frozen_time = Time.now.change(usec: 0) + 1.month
        travel_to(frozen_time) { claim.authorise_part! }

        expect(claim.authorised_at).to eq(frozen_time)
      }
    end
  end

  describe '.is_in_state?' do
    let(:claim) { build :unpersisted_claim }

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
    let!(:claim) { create(:advocate_claim) }
    let!(:expected) do
      {
        event: 'submit',
        from: 'draft',
        to: 'submitted',
        reason_code: []
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

  context 'before submit state transition' do
    it 'sets the allocation_type for trasfer_claims' do
      claim = build(:transfer_claim, transfer_fee: build(:transfer_fee))
      expect(claim.allocation_type).to be nil
      claim.submit!
      expect(claim.allocation_type).to eq 'Grad'
    end
  end

  describe 'reject!' do
    before { claim.submit!; claim.allocate!; claim.reject!(reason_code: reason_codes) }
    let(:reason_codes) { ['no_indictment'] }
    let(:last_state_transition) { claim.last_state_transition }

    context 'claim state transitions (audit trail)' do
      it 'updates #to' do
        expect(last_state_transition.to).to eq('rejected')
      end

      it 'updates #reason_code[s]' do
        expect(last_state_transition.reason_codes).to eq(reason_codes)
      end
    end
  end

  describe 'refuse!' do
    let(:reason_codes) { ['wrong_ia'] }

    context 'when refused on first assessment' do
      before do
        claim.submit!
        claim.allocate!
      end

      context 'claim state transitions (audit trail)' do
        it 'updates #to' do
          expect { claim.refuse!(reason_code: reason_codes) }
            .to change { claim.reload.last_state_transition.to }
            .to 'refused'
        end

        it 'updates #reason_code[s]' do
          expect { claim.refuse!(reason_code: reason_codes) }
            .to change { claim.last_state_transition.reason_codes }
            .to(reason_codes)
        end

        it { expect { claim.refuse!(reason_code: reason_codes) }.not_to change { claim.assessment.fees }.from(0) }

        context 'test' do
          before { claim.refuse!(reason_code: reason_codes) }

          it { expect(claim.assessment.fees).to eq(0) }
        end
      end
    end

    context 'when refused on a redetermination' do
      before do
        claim.submit!
        claim.allocate!
        claim.assessment.update(fees: 123.00, expenses: 23.45)
        claim.authorise_part!
        claim.redetermine!
        claim.allocate!
      end

      it 'does not set the assessment to zero' do
        expect { claim.refuse!(reason_code: reason_codes) }
          .not_to change { claim.assessment.fees.to_f }
          .from(123.0)
      end
    end
  end

  describe '.set_allocation_type' do
    it 'calls the class method' do
      claim = build :transfer_claim
      claim.__send__(:set_allocation_type)
    end
  end
end

require 'rails_helper'

RSpec.describe Claims::StateMachine do
  subject(:claim) { create(:advocate_claim) }

  describe 'state machine' do
    let(:states) do
      %i[
        allocated
        archived_pending_delete
        archived_pending_review
        awaiting_written_reasons
        draft
        authorised
        part_authorised
        refused
        rejected
        redetermination
        submitted
        deallocated
      ]
    end

    it 'has expected states' do
      expect(Claim::BaseClaim.active.state_machine.states.map(&:name).sort).to eq(states.sort)
    end
  end

  describe 'NON_VALIDATION_STATES' do
    subject { described_class::NON_VALIDATION_STATES }

    let(:states) { Claim::BaseClaim.active.state_machine.states.map(&:name).sort }

    it { is_expected.to eql (states - %i[draft submitted]).map(&:to_s) }
  end

  describe '#around_transition' do
    let(:claim) { create(:submitted_claim) }
    let(:assessment) { create(:assessment) }
    let(:case_type) { create(:case_type, :cbr) }

    context 'when all validations are disabled for transitions' do
      transition_event_chains = {
        allocate: %i[allocate!],
        archive_pending_delete: %i[allocate! refuse! archive_pending_delete!],
        await_written_reasons: %i[allocate! refuse! await_written_reasons!],
        deallocate: %i[allocate! deallocate!],
        redetermine: %i[allocate! reject! redetermine!],
        refuse: %i[allocate! refuse!],
        reject: %i[allocate! reject!]
      }

      transition_event_chains.each_value do |events|
        context "when transitioning via event chain #{events}" do
          before do
            *precursor_events, _event = events
            precursor_events.each { |event| claim.send(event) }
          end

          it "##{events.last}" do
            expect(claim).to receive(:disable_for_state_transition=).with(:all).once
            expect(claim).to receive(:disable_for_state_transition=).with(nil).once
            claim.send(events.last)
          end
        end
      end
    end

    context 'when only assessment validations are enabled for transitions' do
      before do
        claim.allocate!
        claim.assessment.update!(fees: 100.00)
      end

      %i[authorise! authorise_part!].each do |transition|
        it "when transitioning via ##{transition}" do
          expect(claim).to receive(:disable_for_state_transition=).with(:only_amount_assessed).once
          expect(claim).to receive(:disable_for_state_transition=).with(nil).once
          claim.send(transition)
        end
      end
    end
  end

  describe 'valid transitions' do
    context 'when current state is redetermination' do
      before do
        claim.submit!
        claim.allocate!
        claim.refuse!
        claim.redetermine!
      end

      it { expect { claim.allocate! }.to change(claim, :state).to('allocated') }
    end

    context 'when current state is awaiting_written_reasons' do
      before do
        claim.submit!
        claim.allocate!
        claim.refuse!
        claim.await_written_reasons!
      end

      it { expect { claim.allocate! }.to change(claim, :state).to('allocated') }
    end

    context 'when current state is allocated' do
      before do
        claim.submit!
        claim.allocate!
      end

      it { expect(claim.assessment).not_to be_nil }
      it { expect(claim.assessment.fees).to eq(0) }
      it { expect(claim.assessment.expenses).to eq(0) }
      it { expect(claim.assessment.disbursements).to eq(0) }
      it { expect { claim.reject! }.to change(claim, :state).to('rejected') }
      it { expect { claim.submit! }.to change(claim, :state).to('submitted') }
      it { expect { claim.refuse! }.to change(claim, :state).to('refused') }

      context 'with an assessed amount' do
        before { claim.assessment.update(fees: 100.00, expenses: 23.45) }

        it { expect { claim.authorise_part! }.to change(claim, :state).to('part_authorised') }
        it { expect { claim.authorise! }.to change(claim, :state).to('authorised') }
      end

      it { expect { claim.archive_pending_delete! }.to raise_error(StateMachines::InvalidTransition) }
      it { expect { claim.deallocate! }.to change(claim, :state).to('submitted') }

      it 'unlinks case workers on deallocate' do
        expect(claim.case_workers).to receive(:destroy_all)
        claim.deallocate!
      end
    end

    context 'when current state is draft' do
      it { expect { claim.submit! }.to change(claim, :state).to('submitted') }
      it { expect { claim.archive_pending_delete! }.to raise_error(StateMachines::InvalidTransition) }
    end

    context 'when current state is authorised' do
      before do
        claim.submit!
        claim.allocate!
        claim.assessment.update(fees: 100.00, expenses: 23.45)
        claim.authorise!
      end

      it { expect { claim.redetermine! }.to change(claim, :state).to('redetermination') }
      it { expect { claim.archive_pending_delete! }.to change(claim, :state).to('archived_pending_delete') }
      it { expect { claim.archive_pending_review! }.to raise_error(StateMachines::InvalidTransition) }

      context 'when it is a hardship claim' do
        subject(:claim) { create(:advocate_hardship_claim) }

        it { expect { claim.archive_pending_review! }.to change(claim, :state).to('archived_pending_review') }
        it { expect { claim.archive_pending_delete! }.to raise_error(StateMachines::InvalidTransition) }
      end
    end

    context 'when current state is part_authorised' do
      before do
        claim.submit!
        claim.allocate!
        claim.assessment.update(fees: 100.00, expenses: 23.45)
        claim.authorise_part!
      end

      it { expect { claim.redetermine! }.to change(claim, :state).to('redetermination') }
      it { expect { claim.await_written_reasons! }.to change(claim, :state).to('awaiting_written_reasons') }
      it { expect { claim.archive_pending_delete! }.to change(claim, :state).to('archived_pending_delete') }
    end

    context 'when current state is refused' do
      before do
        claim.submit!
        claim.allocate!
        claim.refuse!
      end

      it { expect { claim.redetermine! }.to change(claim, :state).to('redetermination') }
      it { expect { claim.await_written_reasons! }.to change(claim, :state).to('awaiting_written_reasons') }
      it { expect { claim.archive_pending_delete! }.to change(claim, :state).to('archived_pending_delete') }
    end

    context 'when current state is rejected' do
      before do
        claim.submit!
        claim.allocate!
        claim.reject!
      end

      it { expect { claim.archive_pending_delete! }.to change(claim, :state).to('archived_pending_delete') }
    end

    context 'when current state is submitted' do
      before { claim.submit! }

      it { expect { claim.allocate! }.to change(claim, :state).to('allocated') }
      it { expect { claim.archive_pending_delete! }.to raise_error(StateMachines::InvalidTransition) }

      context 'when a claim exists with a, legacy, now non-valid evidence provision fee' do
        let(:claim) { create(:litigator_claim) }
        let(:fee) { build(:misc_fee, claim:, amount: '123', fee_type:) }
        let(:fee_type) { build(:misc_fee_type, :mievi) }

        it { expect { claim.allocate! }.not_to raise_error }
      end
    end

    context 'when current state is archived_pending_review' do
      subject(:claim) { create(:advocate_hardship_claim) }

      before do
        claim.submit!
        claim.allocate!
        claim.refuse!
        claim.archive_pending_review!
      end

      it { expect { claim.archive_pending_delete! }.to change(claim, :state).to('archived_pending_delete') }
    end

    context 'when supplier number has been invalidated' do
      let(:claim) { create(:litigator_claim, :fixed_fee, force_validation: true, fixed_fee: build(:fixed_fee, :lgfs)) }

      before { SupplierNumber.find_by(supplier_number: claim.supplier_number).delete }

      it { expect { claim.submit! }.not_to raise_error }
    end

    context 'when a claim exists with a, legacy, now non-valid evidence provision fee' do
      let(:claim) { create(:litigator_claim) }
      let(:fee) { build(:misc_fee, claim:, amount: '123', fee_type:) }
      let(:fee_type) { build(:misc_fee_type, :mievi) }

      before do
        claim.submit!
        claim.allocate!
      end

      it { expect { claim.deallocate! }.not_to raise_error }

      describe 'when part-authorising the claim' do
        it {
          expect do
            claim.assessment.update(fees: 100.00, expenses: 23.45)
            claim.authorise_part!
          end.to change(claim, :state).to('part_authorised')
        }
      end
    end
  end

  describe 'setting dates' do
    context 'when archiving a claim pending deletion' do
      subject(:claim) { create(:authorised_claim) }

      let(:frozen_time) { Time.zone.now.change(usec: 0) }

      before do
        travel_to(frozen_time) { claim.archive_pending_delete! }
      end

      it { expect(claim.valid_until).to eq(frozen_time + 180.days) }
    end

    context 'when submitting a claim' do
      before { freeze_time }

      it 'sets the last_submitted_at to the current time' do
        current_time = Time.zone.now
        claim.submit!
        expect(claim.last_submitted_at).to eq(current_time)
      end

      it 'sets the original_submission_date to the current time' do
        current_time = Time.zone.now
        claim.submit!
        expect(claim.original_submission_date).to eq(current_time)
      end
    end

    context 'when redetermining a claim' do
      let(:current_time) { Time.zone.now.change(usec: 0) }

      before do
        claim.submit!
        claim.allocate!
        claim.refuse!
        travel_to current_time + 6.months do
          claim.redetermine!
        end
      end

      it { expect(claim.last_submitted_at).to eq(current_time + 6.months) }
    end

    context 'when awaiting written reasons on a claim' do
      let(:current_time) { Time.zone.now.change(usec: 0) }

      before do
        claim.submit!
        claim.allocate!
        claim.refuse!
        travel_to current_time + 6.months do
          claim.await_written_reasons!
        end
      end

      it { expect(claim.last_submitted_at).to eq(current_time + 6.months) }
    end

    context 'when authorising a claim' do
      let(:frozen_time) { Time.zone.now.change(usec: 0) + 1.month }

      before do
        claim.submit!
        claim.allocate!
        claim.assessment.update(fees: 100.00, expenses: 23.45)
        travel_to(frozen_time) { claim.authorise! }
      end

      it { expect(claim.authorised_at).to eq(frozen_time) }
    end

    context 'when part-authorising a claim' do
      before do
        claim.submit!
        claim.allocate!
      end

      it {
        claim.assessment.update(fees: 100.00, expenses: 23.45)

        frozen_time = Time.zone.now.change(usec: 0) + 1.month
        travel_to(frozen_time) { claim.authorise_part! }

        expect(claim.authorised_at).to eq(frozen_time)
      }
    end
  end

  describe '.in_state?' do
    let(:claim) { build(:unpersisted_claim) }

    it 'is true if state is in EXTERNAL_USER_DASHBOARD_SUBMITTED_STATES' do
      allow(claim).to receive(:state).and_return('allocated')
      expect(described_class.in_state?(:external_user_dashboard_submitted?, claim)).to be true
    end

    it 'returns false if the state is not one of the EXTERNAL_USER_DASHBOARD_SUBMITTED_STATES' do
      allow(claim).to receive(:state).and_return('draft')
      expect(described_class.in_state?(:external_user_dashboard_submitted?, claim)).to be false
    end

    it 'returns false if the method name is not recognised' do
      allow(claim).to receive(:state).and_return('draft')
      expect(described_class.in_state?(:external_user_rubbish_submitted?, claim)).to be false
    end
  end

  context 'when submitting a transfer claim' do
    let(:claim) { build(:transfer_claim, transfer_fee: build(:transfer_fee), defendants: [build(:defendant)]) }

    before { claim.submit! }

    it { expect(claim.allocation_type).to eq 'Grad' }
  end

  describe 'state transition audit trail' do
    let!(:claim) { create(:advocate_claim) }
    let(:last_state_transition) { claim.last_state_transition }

    context 'when submitting a claim' do
      let!(:expected) do
        {
          event: 'submit',
          from: 'draft',
          to: 'submitted',
          reason_code: []
        }
      end

      before { claim.submit! }

      it { expect(last_state_transition.event).to eq(expected[:event]) }
      it { expect(last_state_transition.from).to eq(expected[:from]) }
      it { expect(last_state_transition.to).to eq(expected[:to]) }
      it { expect(last_state_transition.reason_code).to eq(expected[:reason_code]) }
    end

    context 'when rejecting a claim' do
      let(:reason_codes) { ['no_indictment'] }

      before do
        claim.submit!
        claim.allocate!
        claim.reject!(reason_code: reason_codes)
      end

      it { expect(last_state_transition.to).to eq('rejected') }
      it { expect(last_state_transition.reason_codes).to eq(reason_codes) }
    end

    context 'when refusing a claim' do
      let(:reason_codes) { ['wrong_ia'] }

      context 'when refused on first assessment' do
        before do
          claim.submit!
          claim.allocate!
          claim.refuse!(reason_code: reason_codes)
        end

        it { expect(last_state_transition.to).to eq('refused') }
        it { expect(last_state_transition.reason_codes).to eq(reason_codes) }
        it { expect(claim.assessment.fees).to eq(0) }
      end

      context 'when refused on a redetermination' do
        before do
          claim.submit!
          claim.allocate!
          claim.assessment.update(fees: 123.00, expenses: 23.45)
          claim.authorise_part!
          claim.redetermine!
          claim.allocate!
          claim.refuse!(reason_code: reason_codes)
        end

        it { expect(last_state_transition.to).to eq('refused') }
        it { expect(last_state_transition.reason_codes).to eq(reason_codes) }
        it { expect(claim.assessment.fees).to eq(123.00) }
      end
    end
  end
end

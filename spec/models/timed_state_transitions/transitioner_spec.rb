require 'rails_helper'


module TimedTransitions
  include DatabaseHousekeeping

  describe Transitioner do

    let(:claim)           { double Claim }

    describe '.candidate_states' do
      it 'should return an array of source states for timed transitions' do
        expect(Transitioner.candidate_states).to eq (
          [ :authorised,
            :part_authorised,
            :refused,
            :rejected,
            :archived_pending_delete
          ] )
      end
    end

    describe '.candidate_claim_ids' do
      it 'should generate the correct sql' do
        create :advocate_claim
        create :submitted_claim
        create :allocated_claim
        authorised_claim = create :authorised_claim
        archived_claim = create :archived_pending_delete_claim
        create :redetermination_claim
        part_authorised_claim = create :part_authorised_claim
        refused_claim = create :refused_claim
        rejected_claim = create :rejected_claim
        expected_ids = [ authorised_claim.id, archived_claim.id, part_authorised_claim.id, refused_claim.id, rejected_claim.id ].sort

        expect(Transitioner.candidate_claims_ids.sort).to eq expected_ids
      end
    end

    describe '#run' do
      context 'non dummy run' do
        context 'transitioning to archived pending delete' do
          context 'less than 60 days ago' do
            it 'should not call archive if last state change less than 60 days ago' do
              claim = double Claim
              expect(claim).to receive(:last_state_transition_time).and_return(59.days.ago)
              expect(claim).to receive(:state).and_return('authorised')
              transitioner = Transitioner.new(claim)
              expect(transitioner).not_to receive(:archive)
              transitioner.run
            end
          end

          context 'more than 60 days ago' do
            before(:each) do
              Timecop.freeze(61.days.ago) do
                @claim = create :authorised_claim, case_number: 'Z88299822'
              end
            end

            after(:all) { clean_database }

            it 'should call archive if last state change more than 60 days ago' do
              Transitioner.new(@claim).run
              expect(@claim.reload.state).to eq 'archived_pending_delete'
            end

            it 'writes to the log file' do
              expect_any_instance_of(Logger).to receive(:info).with("Changing state of claim #{@claim_id}: Z88299822 from authorised to archived_pending_delete")
              Transitioner.new(@claim).run
            end


            it 'records the transition in claim state transitions' do
              Transitioner.new(@claim).run
              last_transition = @claim.claim_state_transitions.first
              expect(last_transition.reason_code).to eq('timed_transition')
            end
          end
        end

        context 'destroying' do
          context 'less than 60 days ago' do
            it 'should not call destroy if last state change less than 60 days ago' do
              claim = double Claim
              expect(claim).to receive(:last_state_transition_time).and_return(59.days.ago)
              expect(claim).to receive(:state).and_return('archived_pending_delete')
              transitioner = Transitioner.new(claim)
              expect(transitioner).not_to receive(:destroy)
              transitioner.run
            end
          end

          context 'more than 60 days ago' do
            before(:each) do
              Timecop.freeze(61.days.ago) do
                @claim = create :litigator_claim, :archived_pending_delete, case_number: 'Z88299822'
              end
            end

            after(:all) { clean_database }

            it 'should destroy if last state change more than 60 days ago' do
              Transitioner.new(@claim).run
              expect(Claim::BaseClaim.where(id: @claim.id)).to be_empty
            end

            it 'should destroy all associated records' do
              setup_associations
              Transitioner.new(@claim).run
              expect_claim_and_all_associations_to_be_gone
            end


            it 'writes to the log file' do
              expect_any_instance_of(Logger).to receive(:info).with("Deleting claim : Z88299822")
              Transitioner.new(@claim).run
            end

            def setup_associations
              @claim.defendants.first.representation_orders << RepresentationOrder.new
              2.times { @claim.expenses << Expense.new }
              2.times { @claim.disbursements << create(:disbursement, claim: @claim) }
              2.times { @claim.messages << create(:message, claim: @claim) }
              @claim.expenses.first.dates_attended << DateAttended.new
              @claim.documents << create(:document, claim: @claim, verified: true)
              @claim.certification = create(:certification, claim: @claim)
              @claim.save!
              @claim.reload

              @expense = @claim.expenses.first
              @defendant = @claim.defendants.first
              @document = @claim.documents.first

              expect(@claim.case_worker_claims).not_to be_empty
              expect(@claim.case_workers).not_to be_empty
              expect(@claim.fees).not_to be_empty
              expect(@claim.expenses).not_to be_empty
              expect(@claim.expenses.first.dates_attended).not_to be_empty
              expect(@claim.disbursements).not_to be_empty
              expect(@claim.defendants).not_to be_empty
              expect(@claim.defendants.first.representation_orders).not_to be_empty
              expect(@claim.documents).not_to be_empty
              expect(File.exist?(@claim.documents.first.document.path)).to be true
              expect(@claim.messages).not_to be_empty
              expect(@claim.claim_state_transitions).not_to be_empty
              expect(@claim.determinations).not_to be_empty
              expect(@claim.certification).not_to be_nil
            end

            def expect_claim_and_all_associations_to_be_gone
              expect{ Claim::BaseClaim.find(@claim.id) }.to raise_error ActiveRecord::RecordNotFound, "Couldn't find Claim::BaseClaim with 'id'=#{@claim.id}"
              expect(CaseWorkerClaim.where(claim_id: @claim.id)).to be_empty
              expect(Fee::BaseFee.where(claim_id: @claim_id)).to be_empty
              expect(Expense.where(claim_id: @claim_id)).to be_empty
              expect(DateAttended.where(attended_item_id: @expense_id, attended_item_type: 'Expense')).to be_empty
              expect(Disbursement.where(claim_id: @claim_id)).to be_empty
              expect(Defendant.where(claim_id: @claim_id)).to be_empty
              expect(RepresentationOrder.where(defendant_id: @defendant.id)).to be_empty
              expect(Document.where(claim_id: @claim.id)).to be_empty
              # expect(File.exist?(@document.document.path)).to be false
              expect(Message.where(claim_id: @claim_id)).to be_empty
              expect(ClaimStateTransition.where(claim_id: @claim.id)).to be_empty
              expect(Determination.where(claim_id: @claim.id)).to be_empty
              expect(Certification.where(claim_id: @claim.id)).to be_empty
            end
          end
        end
      end
    end

    describe '#archive' do
      it 'should call archive pending delete on the claim' do
        transitioner = Transitioner.new(claim)
        expect(claim).to receive(:case_number).and_return('A12345678')
        expect(claim).to receive(:state).and_return('part_authorised')
        expect(claim).to receive(:archive_pending_delete!)
        transitioner.send(:archive, false)
      end
    end

    describe '#destroy' do
      it 'should call destroy on the claim' do
        transitioner = Transitioner.new(claim)
        expect(claim).to receive(:case_number).and_return('A12345678')
        expect(claim).to receive(:destroy)
        transitioner.send(:destroy, false)
      end
    end

  end

end
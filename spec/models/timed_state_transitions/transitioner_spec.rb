require 'rails_helper'


module TimedTransitions
  include DatabaseHousekeeping

  describe Transitioner do

    let(:claim)           { double Claim }

    describe '.candidate_states' do
      it 'should return an array of source states for timed transitions' do
        expect(Transitioner.candidate_states).to eq (
          [ :draft,
            :authorised,
            :part_authorised,
            :refused,
            :rejected,
            :archived_pending_delete
          ] )
      end
    end

    describe '.candidate_claim_ids' do
      it 'returns a list of ids in the target states' do
        draft_claim = authorised_claim = archived_claim = part_authorised_claim = refused_claim = rejected_claim = nil

        Timecop.freeze(18.weeks.ago) do
          draft_claim = create :advocate_claim
          create :submitted_claim
          create :allocated_claim
          authorised_claim = create :authorised_claim
          archived_claim = create :archived_pending_delete_claim
          create :redetermination_claim
          part_authorised_claim = create :part_authorised_claim
          refused_claim = create :refused_claim
          rejected_claim = create :rejected_claim
        end

        # This claim will not meet the time scope
        create :advocate_claim

        expected_ids = [ draft_claim.id, authorised_claim.id, archived_claim.id, part_authorised_claim.id, refused_claim.id, rejected_claim.id ].sort
        expect(Transitioner.candidate_claims_ids.sort).to eq expected_ids
      end
    end

    describe '.softly_deleted_ids' do
      it 'returns ids of claims that were softly deleted more than 16 weeks ago' do
        claim_a = claim_b = claim_c = nil
        Timecop.freeze(18.weeks.ago) { claim_a, claim_b, claim_c = create_list :advocate_claim, 3 }
        Timecop.freeze(17.weeks.ago) { claim_a.soft_delete }
        Timecop.freeze(15.weeks.ago) { claim_b.soft_delete }
        ids = Transitioner.softly_deleted_ids
        expect(ids).not_to include(claim_c.id)
        expect(ids).not_to include(claim_b.id)
        expect(ids).to include(claim_a.id)
      end

    end

    describe '#run' do
      context 'non dummy run' do
        context 'transitioning to archived pending delete' do
          context 'less than 60 days ago' do
            it 'should not call archive if last state change less than 60 days ago' do
              claim = double Claim
              expect(claim).to receive(:last_state_transition_time).at_least(:once).and_return(15.weeks.ago)
              expect(claim).to receive(:state).and_return('authorised')
              expect(claim).to receive(:softly_deleted?).and_return(false)
              transitioner = Transitioner.new(claim)
              expect(transitioner).not_to receive(:archive)
              expect(LogStuff).not_to receive(:info)
              transitioner.run
            end
          end

          context 'more than 16 weeks ago' do
            before(:each) do
              Timecop.freeze(17.weeks.ago) do
                @claim = create :authorised_claim, case_number: 'A20164444'
              end
            end

            it 'records success' do
              t = Transitioner.new(@claim)
              t.run
              expect(t.success?).to be true
            end

            it 'should call archive if last state change more than 16 weeks ago' do
              Transitioner.new(@claim).run
              expect(@claim.reload.state).to eq 'archived_pending_delete'
            end

            it 'writes to the log file' do
              expect(LogStuff).to receive(:info).with('TimedTransitions::Transitioner',
                                                      action: 'archive',
                                                      claim_id: @claim.id,
                                                      softly_deleted_on: @claim.deleted_at,
                                                      dummy_run: false)
              Transitioner.new(@claim).run
            end


            it 'records the transition in claim state transitions' do
              Transitioner.new(@claim).run
              last_transition = @claim.reload.claim_state_transitions.first
              expect(last_transition.reason_code).to eq(['timed_transition'])
            end


            context 'when the claim has been invalidated' do
              let(:litigator) { create(:external_user, :litigator) }
              before do
                @claim.creator = litigator
                Transitioner.new(@claim).run
              end

              it 'still transitions to archived_pending_delete' do
                expect(@claim.reload.state).to eq 'archived_pending_delete'
              end
            end
          end
        end

        context 'destroying' do
          context 'soft-deleted claim more than 16 weeks ago' do
            let(:claim) { create :archived_pending_delete_claim }

            it 'should destroy the claim' do
              expect(claim).to receive(:softly_deleted?).and_return(true)
              expect(claim).to receive(:destroy)
              Transitioner.new(claim).run
            end

            it 'creates an MI version of the record' do
              expect(claim).to receive(:softly_deleted?).and_return(true)
              expect(claim).to receive(:destroy)
              expect { Transitioner.new(claim).run }.to change { Stats::MIData.count }.by 1 
            end
          end

          context 'less than 60 days ago' do
            it 'should not call destroy if last state change less than 16 weeks ago' do
              claim = double Claim
              expect(claim).to receive(:last_state_transition_time).at_least(:once).and_return(15.weeks.ago)
              expect(claim).to receive(:state).and_return('archived_pending_delete')
              expect(claim).to receive(:softly_deleted?).and_return(false)
              transitioner = Transitioner.new(claim)
              expect(transitioner).not_to receive(:destroy_claim)
              transitioner.run
            end
          end

          context 'more than 16 weeks ago' do
            before(:each) do
              Timecop.freeze(17.weeks.ago) do
                @claim = create :litigator_claim, :archived_pending_delete, case_number: 'A20164444'
              end
            end

            after(:all) { clean_database }

            it 'should destroy if last state change more than 60 days ago' do
              Transitioner.new(@claim).run
              expect(Claim::BaseClaim.where(id: @claim.id)).to be_empty
            end

            it 'should destroy all associated records', delete: true do
              setup_associations
              Transitioner.new(@claim).run
              expect_claim_and_all_associations_to_be_gone
            end


            it 'writes to the log file' do
              expect(LogStuff).to receive(:info).with('TimedTransitions::Transitioner',
                            action: 'destroy',
                            claim_id: @claim.id,
                            claim_state: @claim.state,
                            softly_deleted_on: @claim.deleted_at,
                            dummy_run: false)
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
              expect(File.exist?(@claim.documents.first.converted_preview_document.path)).to be true
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
              expect(File.exist?(@document.document.path)).to be false
              expect(File.exist?(@document.converted_preview_document.path)).to be false
              expect(Message.where(claim_id: @claim_id)).to be_empty
              expect(ClaimStateTransition.where(claim_id: @claim.id)).to be_empty
              expect(Determination.where(claim_id: @claim.id)).to be_empty
              expect(Certification.where(claim_id: @claim.id)).to be_empty
            end
          end
        end
      end

      context 'dummy run' do
        context 'transitioning to archived pending delete' do
          context 'less than 60 days ago' do
            it 'should not call archive if last state change less than 60 days ago' do
              claim = double Claim
              expect(claim).to receive(:last_state_transition_time).at_least(:once).and_return(15.weeks.ago)
              expect(claim).to receive(:state).and_return('authorised')
              expect(claim).to receive(:softly_deleted?).and_return(false)
              transitioner = Transitioner.new(claim, true)
              expect(transitioner).not_to receive(:archive)
              expect(LogStuff).not_to receive(:debug)
              transitioner.run()
            end
          end

          context 'more than 16 weeks ago' do
            before(:each) do
              Timecop.freeze(17.weeks.ago) do
                @claim = create :authorised_claim, case_number: 'A20164444'
              end
            end

            it 'leaves the claim in authorised state' do
              Transitioner.new(@claim, true).run
              expect(@claim.reload.state).to eq 'authorised'
            end

            it 'writes to the log file' do
              expect(LogStuff).to receive(:debug).with('TimedTransitions::Transitioner',
                                                      action: 'archive',
                                                      claim_id: @claim.id,
                                                      softly_deleted_on: @claim.deleted_at,
                                                      dummy_run: true)
              Transitioner.new(@claim, true).run
            end


            it 'does not record a timed_transition in claim state transitions' do
              Transitioner.new(@claim, true).run
              expect(@claim.claim_state_transitions.map(&:reason_code)).not_to include('timed_transition')
            end
          end
        end

        context 'destroying' do
          context 'less than 60 days ago' do
            it 'should not call destroy if last state change less than 16 weeks ago' do
              claim = double Claim
              expect(claim).to receive(:last_state_transition_time).at_least(:once).and_return(15.weeks.ago)
              expect(claim).to receive(:state).and_return('archived_pending_delete')
              expect(claim).to receive(:softly_deleted?).and_return(false)
              transitioner = Transitioner.new(claim, true)
              expect(transitioner).not_to receive(:destroy_claim)
              expect(LogStuff).not_to receive(:debug)
              transitioner.run
            end
          end

          context 'more than 16 weeks ago' do
            before(:each) do
              Timecop.freeze(17.weeks.ago) do
                @claim = create :litigator_claim, :archived_pending_delete, case_number: 'A20164444'
              end
            end

            it 'should not destroy the claim' do
              Transitioner.new(@claim, true).run
              expect(Claim::BaseClaim.where(id: @claim.id)).not_to be_empty
            end

            it 'should not destroy all associated records' do
              setup_associations
              Transitioner.new(@claim, true).run
              expect_claim_and_all_associations_to_be_present
            end


            it 'writes to the log file' do
              expect(LogStuff).to receive(:debug).with('TimedTransitions::Transitioner',
                                                      action: 'destroy',
                                                      claim_id: @claim.id,
                                                      claim_state: @claim.state,
                                                      softly_deleted_on: @claim.deleted_at,
                                                      dummy_run: true)
              Transitioner.new(@claim, true).run
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
              expect(Fee::BaseFee.where(claim_id: @claim.id)).to be_empty
              expect(Expense.where(claim_id: @claim.id)).to be_empty
              expect(DateAttended.where(attended_item_id: @expense.id, attended_item_type: 'Expense')).to be_empty
              expect(Disbursement.where(claim_id: @claim.id)).to be_empty
              expect(Defendant.where(claim_id: @claim.id)).to be_empty
              expect(RepresentationOrder.where(defendant_id: @defendant.id)).to be_empty
              expect(Document.where(claim_id: @claim.id)).to be_empty
              # expect(File.exist?(@document.document.path)).to be false
              expect(Message.where(claim_id: @claim.id)).to be_empty
              expect(ClaimStateTransition.where(claim_id: @claim.id)).to be_empty
              expect(Determination.where(claim_id: @claim.id)).to be_empty
              expect(Certification.where(claim_id: @claim.id)).to be_empty
            end

            def expect_claim_and_all_associations_to_be_present
              expect(Claim::BaseClaim.find(@claim.id)).to eq @claim
              expect(CaseWorkerClaim.where(claim_id: @claim.id)).not_to be_empty
              expect(Fee::BaseFee.where(claim_id: @claim.id)).not_to be_empty
              expect(Expense.where(claim_id: @claim.id)).not_to be_empty
              expect(DateAttended.where(attended_item_id: @expense.id, attended_item_type: 'Expense')).not_to be_empty
              expect(Disbursement.where(claim_id: @claim.id)).not_to be_empty
              expect(Defendant.where(claim_id: @claim.id)).not_to be_empty
              expect(RepresentationOrder.where(defendant_id: @defendant.id)).not_to be_empty
              expect(Document.where(claim_id: @claim.id)).not_to be_empty
              expect(Message.where(claim_id: @claim.id)).not_to be_empty
              expect(ClaimStateTransition.where(claim_id: @claim.id)).not_to be_empty
              expect(Determination.where(claim_id: @claim.id)).not_to be_empty
              expect(Certification.where(claim_id: @claim.id)).not_to be_empty
            end
          end
        end
      end
    end
    end
end
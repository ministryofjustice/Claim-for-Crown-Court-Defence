require 'rails_helper'


module Claims
  describe CaseWorkerClaimUpdater do

    context 'assessments' do

      let(:claim) { create :allocated_claim }
      let(:submitted_claim) { create :claim, :submitted }

      context 'successful transitions' do
        it 'advances the claim to part authorised' do
          params = {'state' => 'part_authorised', 'assessment_attributes' => {'fees' => '45', 'expenses' => '0.00'}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :ok
          expect(updater.claim.state).to eq 'part_authorised'
          expect(updater.claim.assessment.fees).to eq 45.0
          expect(updater.claim.assessment.expenses).to eq 0.0
          expect(updater.claim.assessment.disbursements).to eq 0.0
        end

        it 'advances the claim to authorised' do
          params = {'state' => 'authorised', 'assessment_attributes' => {'fees' => '128.33', 'expenses' => '42.88'}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :ok
          expect(updater.claim.state).to eq 'authorised'
          expect(updater.claim.assessment.fees.to_f).to eq 128.33
          expect(updater.claim.assessment.expenses).to eq 42.88
          expect(updater.claim.assessment.disbursements).to eq 0.0
        end

        context 'rejections' do
          let(:params) { {'state' => 'rejected', 'assessment_attributes' => {'fees' => '', 'expenses' => '0'}} }
          let(:reason_param) { {'state_reason' => 'no_indictment'} }

          it 'advances the claim to rejected when no values are supplied' do
            updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
            expect(updater.result).to eq :ok
            expect(updater.claim.state).to eq 'rejected'
            expect(updater.claim.assessment).to be_zero
          end

          it 'advances the claim to rejected with reason supplied' do
            updater = CaseWorkerClaimUpdater.new(claim.id, params.merge(reason_param)).update!
            expect(updater.result).to eq :ok
            expect(updater.claim.state).to eq 'rejected'
            expect(updater.claim.last_state_transition.reason_code).to eq 'no_indictment'
          end
        end

        it 'advances the claim to refused when no values are supplied' do
          params = {'state' => 'refused', 'assessment_attributes' => {'expenses' => ''}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :ok
          expect(updater.claim.state).to eq 'refused'
          expect(updater.claim.assessment).to be_zero
        end
      end

      context 'errors' do
        it 'errors if part auth selected and no values' do
          params = {'assessment_attributes'=>{'fees'=>'0.00', 'expenses'=>'0.00', 'id'=>'3'}, 'state'=>'part_authorised'}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.assessment).to be_zero
          expect(updater.claim.errors[:determinations]).to eq(['You must specify positive values if authorising or part authorising a claim'])
        end

        it 'errors if assessment data is present in the params but no state specified' do
          params = {'state' => '', 'assessment_attributes' => {'fees' => '128.33', 'expenses' => '42.88'}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:determinations]).to eq(['You must specify authorised or part authorised if you supply values'])
        end

        it 'errors if values are supplied with refused' do
          params = {'state' => 'refused', 'assessment_attributes' => {'fees' => '93.65','expenses' => '42.88'}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:determinations]).to eq(['You cannot specify values when refusing a claim'])
          expect(updater.claim.state).to eq 'allocated'
          expect(updater.claim.assessment.fees.to_f).to eq 0.0
          expect(updater.claim.assessment.expenses).to eq 0.0
          expect(updater.claim.assessment.disbursements).to eq 0.0
        end

        it 'errors if values are supplied with rejected' do
          params = {'state' => 'rejected', 'assessment_attributes' => {'fees' => '93.65','expenses' => '42.88'}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:determinations]).to eq(['You cannot specify values when rejecting a claim'])
          expect(updater.claim.state).to eq 'allocated'
          expect(updater.claim.assessment.fees.to_f).to eq 0.0
          expect(updater.claim.assessment.expenses).to eq 0.0
          expect(updater.claim.assessment.disbursements).to eq 0.0
        end

        it 'rollbacks the transaction if transition fails' do
          expect(submitted_claim.assessment.fees.to_f).to eq 0.0

          params = {'state' => 'authorised', 'assessment_attributes' => {'fees' => '200', 'expenses' => '0.00'}}
          updater = CaseWorkerClaimUpdater.new(submitted_claim.id, params).update!

          expect(updater.result).to eq :error
          expect(updater.claim.errors[:determinations]).to eq(['Cannot transition state via :authorise from :submitted (Reason(s): State cannot transition via "authorise")'])

          # objects will not have their instance data returned to their pre-transactional state
          expect(updater.claim.assessment.fees.to_f).to eq 200.0
          updater.claim.reload
          expect(updater.claim.state).to eq 'submitted'
          expect(updater.claim.assessment.fees.to_f).to eq 0.0
        end
      end
    end

    context 'redeterminations' do

      let(:claim)  {
        klaim = create :allocated_claim
        klaim.assessment.update(fees: 200.15, expenses: 77.66)
        klaim
      }

      context 'successful transitions' do
        it 'advances the claim to part authorised' do
          params = {'state' => 'part_authorised', 'redeterminations_attributes' => {'0' => {'fees' => '45', 'expenses' => '0.00'}}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :ok
          expect(updater.claim.state).to eq 'part_authorised'
          expect(updater.claim.redeterminations.first.fees).to eq 45.0
          expect(updater.claim.redeterminations.first.expenses).to eq 0.0
          expect(updater.claim.redeterminations.first.disbursements).to eq 0.0
        end

        it 'advances the claim to authorised' do
          params = {'state' => 'authorised', 'redeterminations_attributes' => {'0' => {'fees' => '', 'expenses' => '230.00'}}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :ok
          expect(updater.claim.state).to eq 'authorised'
          expect(updater.claim.redeterminations.first.fees.to_f).to eq 0.0
          expect(updater.claim.redeterminations.first.expenses).to eq 230.0
          expect(updater.claim.redeterminations.first.disbursements).to eq 0.0
        end

        it 'advances the claim to rejected when no values are supplied' do
          params = {'state' => 'rejected', 'redeterminations_attributes' => {'0' => {'fees' => '', 'expenses' => '0'}}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :ok
          expect(updater.claim.state).to eq 'rejected'
          expect(updater.claim.redeterminations).to be_empty
        end

        it 'advances the claim to refused when no values are supplied' do
          params = {'state' => 'refused'}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :ok
          expect(updater.claim.state).to eq 'refused'
          expect(updater.claim.redeterminations).to be_empty
        end
      end


      context 'errors' do
        it 'errors if assessment data is present in the params but no state specified' do
          params = {'state' => '', 'redeterminations_attributes' => {'0' => {'fees' => '128.33', 'expenses' => '42.40'}}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:determinations]).to eq(['You must specify authorised or part authorised if you supply values'])
        end

        it 'errors if values are supplied with refused' do
          params = {'state' => 'refused', 'redeterminations_attributes' => {'0' => {'fees' => '128.33', 'expenses' => '42.40'}}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:determinations]).to eq(['You cannot specify values when refusing a claim'])
          expect(updater.claim.state).to eq 'allocated'
          expect(updater.claim.redeterminations).to be_empty
        end

        it 'errors if values are supplied with rejected' do
          params = {'state' => 'rejected', 'redeterminations_attributes' => {'0' => {'fees' => '128.33', 'expenses' => '42.40'}}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:determinations]).to eq(['You cannot specify values when rejecting a claim'])
          expect(updater.claim.state).to eq 'allocated'
          expect(updater.claim.redeterminations).to be_empty
        end
      end
    end
  end
end


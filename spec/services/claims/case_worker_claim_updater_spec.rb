require 'rails_helper'

module Claims
  describe CaseWorkerClaimUpdater do

    RSpec.shared_examples 'a successful non-authorised claim with a single reason' do |state|
      it_behaves_like 'base_test', state, ['no_indictment']
    end

    RSpec.shared_examples 'a successful non-authorised claim with other as reason' do |state|
      it_behaves_like 'base_test', state, ['other'], 'a reason'
    end

    RSpec.shared_examples 'base_test' do |state, state_reason, reason_text=nil|
      subject(:updater) { CaseWorkerClaimUpdater.new(claim.id, params.merge(current_user: current_user)).update! }
      let(:claim) { create :allocated_claim }
      let(:current_user) { double(User, id: 12345) }
      let(:params) { {'state' => state, 'state_reason' => state_reason, 'reason_text' => reason_text, 'assessment_attributes' => {'fees' => '', 'expenses' => '0'}} }

      it 'updates the state to `other` and returns OK' do
        expect(updater.result).to eq :ok
        expect(updater.claim.state).to eq state
        expect(updater.claim.last_state_transition.reason_code).to eq state_reason
        expect(updater.claim.last_state_transition.reason_text).to eq reason_text
        expect(updater.claim.last_state_transition.author_id).to eq(current_user.id)
      end
    end

    RSpec.shared_examples 'a successful assessment' do |state, fees='128.33', expenses='42.40'|
      subject(:updater) { CaseWorkerClaimUpdater.new(claim.id, params.merge(current_user: current_user)).update! }
      let(:claim) { create :allocated_claim }
      let(:current_user) { double(User, id: 12345) }
      let(:params) { {'state' => state, 'assessment_attributes' => {'fees' => fees, 'expenses' => expenses}} }

      it 'sets the result to error' do
        expect(updater.result).to eq :ok
        expect(updater.claim.state).to eq state
        expect(updater.claim.assessment.fees).to eq fees
        expect(updater.claim.assessment.expenses).to eq expenses
        expect(updater.claim.assessment.disbursements).to eq 0.0
        expect(updater.claim.last_state_transition.author_id).to eq(current_user.id)
      end
    end

    RSpec.shared_examples 'a failing assessment' do |state, expected_error, update_type='redeterminations', state_reason=nil, fees='128.33', expenses='42.40', error_field=:determinations|
      subject(:updater) { CaseWorkerClaimUpdater.new(claim.id, params.merge(current_user: current_user)).update! }
      let(:claim) { create :allocated_claim }
      let(:current_user) { double(User, id: 12345) }
      let(:params) { {'state' => state, 'state_reason' => state_reason, "#{update_type}_attributes" => {'0' => {'fees' => fees, 'expenses' => expenses}}} }

      it 'sets the result to error' do
        expect(updater.result).to eq :error
        expect(updater.claim.errors[error_field]).to eq(expected_error)
        expect(updater.claim.state).to eq 'allocated'
        expect(updater.claim.redeterminations).to be_empty
      end
    end

    context 'assessments' do

      let(:claim) { create :allocated_claim }
      let(:submitted_claim) { create :claim, :submitted }
      let(:current_user) { double(User, id: 12345) }

      context 'successful transitions' do
        context 'advances the claim to part authorised' do
          it_behaves_like 'a successful assessment', 'part_authorised', 45.0, 0
        end

        context 'advances the claim to authorised' do
          it_behaves_like 'a successful assessment', 'authorised', 128.33, 42.88
        end

        context 'rejections' do
          it_behaves_like 'a successful non-authorised claim with a single reason', 'rejected'
          it_behaves_like 'a successful non-authorised claim with other as reason', 'rejected'
        end

        context 'refusals' do
          it_behaves_like 'a successful non-authorised claim with a single reason', 'refused'
          it_behaves_like 'a successful non-authorised claim with other as reason', 'refused'
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
        it 'errors if no state and and no values submitted' do
          params = {'assessment_attributes'=>{'fees'=>'0.00', 'expenses'=>'0.00', 'id'=>'3'}, 'state'=>''}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.assessment).to be_zero
          expect(updater.claim.errors[:determinations]).to eq(['You should select a status'])
        end

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

        it 'if rejected and no state_reason are supplied' do
          params = {'state' => 'rejected', 'state_reason' => [''], 'assessment_attributes' => {'fees' => '', 'expenses' => '0'}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:rejected_reason]).to eq(['requires a reason when rejecting'])
          expect(updater.claim.state).to eq 'allocated'
          expect(updater.claim.assessment.fees.to_f).to eq 0.0
          expect(updater.claim.assessment.expenses).to eq 0.0
          expect(updater.claim.assessment.disbursements).to eq 0.0
        end

        it 'if rejected, state_reason is other and no text is supplied' do
          params = {'state' => 'rejected', 'state_reason' => ['other'], 'assessment_attributes' => {'fees' => '', 'expenses' => '0'}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:rejected_reason_other]).to eq(['needs a description'])
          expect(updater.claim.state).to eq 'allocated'
          expect(updater.claim.assessment.fees.to_f).to eq 0.0
          expect(updater.claim.assessment.expenses).to eq 0.0
          expect(updater.claim.assessment.disbursements).to eq 0.0
        end

        it 'if refused and no state_reason are supplied' do
          params = {'state' => 'refused', 'state_reason' => [''], 'assessment_attributes' => {'fees' => '', 'expenses' => '0'}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:refused_reason]).to eq(['requires a reason when refusing'])
          expect(updater.claim.state).to eq 'allocated'
          expect(updater.claim.assessment.fees.to_f).to eq 0.0
          expect(updater.claim.assessment.expenses).to eq 0.0
          expect(updater.claim.assessment.disbursements).to eq 0.0
        end

        it 'if refused, state_reason is other and no text is supplied' do
          params = {'state' => 'refused', 'state_reason' => ['other'], 'assessment_attributes' => {'fees' => '', 'expenses' => '0'}}
          updater = CaseWorkerClaimUpdater.new(claim.id, params).update!
          expect(updater.result).to eq :error
          expect(updater.claim.errors[:refused_reason_other]).to eq(['needs a description'])
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

        context 'if values are supplied with refused' do
          it_behaves_like 'a failing assessment', 'refused', ['You cannot specify values when refusing a claim']
        end

        context 'if values are supplied with rejected' do
          it_behaves_like 'a failing assessment', 'rejected', ['You cannot specify values when rejecting a claim']
        end

        context 'if no state_reason are supplied' do
          it_behaves_like 'a failing assessment', 'rejected', ['requires a reason when rejecting'], 'redeterminations', [''], '', 0, :rejected_reason
        end

        context 'if state_reason is other, but no text is supplied' do
          it_behaves_like 'a failing assessment', 'rejected', ['needs a description'], 'redeterminations', ['other'], 0, 0, :rejected_reason_other
        end
      end
    end
  end
end


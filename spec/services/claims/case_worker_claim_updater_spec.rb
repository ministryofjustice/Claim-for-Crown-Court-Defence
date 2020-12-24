require 'rails_helper'

RSpec.describe Claims::CaseWorkerClaimUpdater do
  let(:current_user) { create(:user) }

  shared_examples 'a successful non-authorised claim with a single reason' do |state|
    it_behaves_like 'non-authorised claim', state, ['no_indictment']
  end

  shared_examples 'a successful non-authorised claim with other as reason' do |state, state_reason = ['other']|
    it_behaves_like 'non-authorised claim', state, state_reason, 'a reason'
  end

  shared_examples 'non-authorised claim' do |state, state_reason, reason_text = nil|
    subject(:updater) { described_class.new(claim.id, params.merge(current_user: current_user)) }
    let(:claim) { create :allocated_claim }
    let(:params) do
      {
        'state' => state,
        'state_reason' => state_reason,
        "#{state.eql?('rejected') ? 'reject' : 'refuse'}_reason_text" => reason_text,
        'assessment_attributes' => { 'fees' => '', 'expenses' => '0' }
      }
    end

    before do |example|
      updater.update! unless example.metadata[:wait]
    end

    it 'returns :ok' do
      expect(updater.result).to eq :ok
    end

    it "updates state to #{state}" do
      expect(updater.claim.state).to eq state
    end

    it 'adds claim state transition details' do
      expect(updater.claim.last_state_transition.reason_code).to eq state_reason
      expect(updater.claim.last_state_transition.reason_text).to eq reason_text
      expect(updater.claim.last_state_transition.author_id).to eq(current_user.id)
    end

    it 'adds message to the claim', :wait do
      expect { updater.update! }.to change(updater.claim.messages, :count).by(1)
    end
  end

  shared_examples 'a successful assessment' do |state, fees = '128.33', expenses = '42.40'|
    subject(:updater) { described_class.new(claim.id, params.merge(current_user: current_user)) }
    let(:claim) { create :allocated_claim }
    let(:params) do
      {
        'state' => state,
        'state_reason' => [],
        'reject_reason_text' => '',
        'refuse_reason_text' => '',
        'assessment_attributes' => { 'fees' => fees, 'expenses' => expenses }
      }
    end

    before do |example|
      updater.update! unless example.metadata[:wait]
    end

    it 'returns :ok' do
      expect(updater.result).to eq :ok
    end

    it "updates state to #{state}" do
      expect(updater.claim.state).to eq state
    end

    it 'updates the assessment' do
      expect(updater.claim.assessment.fees).to eq fees
      expect(updater.claim.assessment.expenses).to eq expenses
      expect(updater.claim.assessment.disbursements).to eq 0.0
    end

    it 'adds claim state transition details' do
      expect(updater.claim.last_state_transition.reason_code).to be_empty
      expect(updater.claim.last_state_transition.reason_text).to be_blank
      expect(updater.claim.last_state_transition.author_id).to eq(current_user.id)
    end

    it 'does not add message to the claim', :wait do
      expect { updater.update! }.to_not change(updater.claim.messages, :count)
    end
  end

  shared_examples 'an erroneous determination' do |state, expected_error, determination_type = 'redeterminations', state_reason = [], fees = '128.33', expenses = '42.40', error_field = :determinations|
    subject(:updater) { described_class.new(claim.id, params.merge(current_user: current_user)) }
    let(:claim) { create :allocated_claim }
    let(:assessment_attributes) { { 'fees' => fees, 'expenses' => expenses } }
    let(:redeterminations_attributes) { { '0' => { 'fees' => fees, 'expenses' => expenses } } }
    let(:params) do
      {
        'state' => state,
        'state_reason' => state_reason,
        'reject_reason_text' => '',
        'refuse_reason_text' => '',
        "#{determination_type}_attributes" => send("#{determination_type}_attributes")
      }
    end

    before do |example|
      updater.update! unless example.metadata[:wait]
    end

    it 'returns :error' do
      expect(updater.result).to eq :error
    end

    it 'does NOT update state' do
      expect(updater.claim.state).to eq 'allocated'
    end

    it "does NOT add #{determination_type}" do
      expect(updater.claim.redeterminations).to be_empty if determination_type.eql?('redeterminations')
      expect(updater.claim.assessment.total).to be_zero if determination_type.eql?('assessment')
    end

    it 'does NOT add message to the claim', :wait do
      expect { updater.update! }.to_not change(updater.claim.messages, :count)
    end

    it 'adds errors on claim' do
      expect(updater.claim.errors[error_field]).to eq(expected_error)
    end
  end

  context 'assessments' do
    let(:claim) { create :allocated_claim }

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
        it_behaves_like 'a successful non-authorised claim with other as reason', 'refused', ['other_refuse']
      end

      # Not sure what this is testing beyond that covered by above. remove?
      it 'advances the claim to refused when no values are supplied' do
        params = { current_user: current_user, 'state' => 'refused', 'state_reason' => %w[wrong_ia duplicate_claim], 'assessment_attributes' => { 'expenses' => '' } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :ok
        expect(updater.claim.state).to eq 'refused'
        expect(updater.claim.assessment).to be_zero
      end
    end

    context 'errors' do
      it 'errors if no state and and no values submitted' do
        params = { 'assessment_attributes' => { 'fees' => '0.00', 'expenses' => '0.00', 'id' => '3' }, 'state' => '' }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.assessment).to be_zero
        expect(updater.claim.errors[:determinations]).to eq(['must select a status'])
      end

      it 'errors if part auth selected and no values' do
        params = { 'assessment_attributes' => { 'fees' => '0.00', 'expenses' => '0.00', 'id' => '3' }, 'state' => 'part_authorised' }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.assessment).to be_zero
        expect(updater.claim.errors[:determinations]).to include('require values when authorising')
      end

      it 'errors if assessment data is present in the params but no state specified' do
        params = { 'state' => '', 'assessment_attributes' => { 'fees' => '128.33', 'expenses' => '42.88' } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.errors[:determinations]).to include('must select a status')
      end

      it 'errors if values are supplied with refused' do
        params = { 'state' => 'refused', 'assessment_attributes' => { 'fees' => '93.65','expenses' => '42.88' } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.errors[:determinations]).to include('must not have values when refusing a claim')
        expect(updater.claim.state).to eq 'allocated'
        expect(updater.claim.assessment.fees.to_f).to eq 0.0
        expect(updater.claim.assessment.expenses).to eq 0.0
        expect(updater.claim.assessment.disbursements).to eq 0.0
      end

      it 'errors if values are supplied with rejected' do
        params = { 'state' => 'rejected', 'assessment_attributes' => { 'fees' => '93.65','expenses' => '42.88' } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.errors[:determinations]).to include('must not have values when rejecting a claim')
        expect(updater.claim.state).to eq 'allocated'
        expect(updater.claim.assessment.fees.to_f).to eq 0.0
        expect(updater.claim.assessment.expenses).to eq 0.0
        expect(updater.claim.assessment.disbursements).to eq 0.0
      end

      it 'if rejected and no state_reason are supplied' do
        params = { 'state' => 'rejected', 'state_reason' => [''], 'assessment_attributes' => { 'fees' => '', 'expenses' => '0' } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.errors[:rejected_reason]).to include('requires a reason')
        expect(updater.claim.state).to eq 'allocated'
        expect(updater.claim.assessment.fees.to_f).to eq 0.0
        expect(updater.claim.assessment.expenses).to eq 0.0
        expect(updater.claim.assessment.disbursements).to eq 0.0
      end

      it 'if rejected, state_reason is other and no text is supplied' do
        params = { 'state' => 'rejected', 'state_reason' => ['other'], 'assessment_attributes' => { 'fees' => '', 'expenses' => '0' } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.errors[:rejected_reason_other]).to include('needs a description')
        expect(updater.claim.state).to eq 'allocated'
        expect(updater.claim.assessment.fees.to_f).to eq 0.0
        expect(updater.claim.assessment.expenses).to eq 0.0
        expect(updater.claim.assessment.disbursements).to eq 0.0
      end

      it 'if refused and no state_reason are supplied' do
        params = { 'state' => 'refused', 'state_reason' => [''], 'assessment_attributes' => { 'fees' => '', 'expenses' => '0' } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.errors[:refused_reason]).to include('requires a reason')
        expect(updater.claim.state).to eq 'allocated'
        expect(updater.claim.assessment.fees.to_f).to eq 0.0
        expect(updater.claim.assessment.expenses).to eq 0.0
        expect(updater.claim.assessment.disbursements).to eq 0.0
      end

      it 'if refused, state_reason is other and no text is supplied' do
        params = { 'state' => 'refused', 'state_reason' => ['other'], 'assessment_attributes' => { 'fees' => '', 'expenses' => '0' } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.errors[:refused_reason_other]).to include('needs a description')
        expect(updater.claim.state).to eq 'allocated'
        expect(updater.claim.assessment.fees.to_f).to eq 0.0
        expect(updater.claim.assessment.expenses).to eq 0.0
        expect(updater.claim.assessment.disbursements).to eq 0.0
      end

      context 'transactional rollback' do
        subject(:updater) { described_class.new(claim.id, params).update! }
        let(:claim) { create :claim, :submitted }
        let(:params) { { 'state' => 'authorised', 'assessment_attributes' => { 'fees' => '200', 'expenses' => '0.00' } } }

        it 'returns result of :error' do
          expect(updater.result).to eq :error
        end

        it 'adds error to its instance claim object' do
          expect(updater.claim.errors[:determinations]).to include('Cannot transition state via :authorise from :submitted (Reason(s): State cannot transition via "authorise")')
        end

        it 'instance data remains in pre-transactional state' do
          expect(updater.claim.assessment.fees.to_f).to eq 200.0
        end

        it 'does not persist the change' do
          expect(claim.assessment.fees.to_f).to eq 0.0
          updater.claim.reload
          expect(updater.claim.state).to eq 'submitted'
          expect(updater.claim.assessment.fees.to_f).to eq 0.0
        end
      end
    end
  end

  context 'rejections' do
    subject(:updater) { described_class.new(claim.id, params.merge(current_user: current_user)) }
    let(:claim) { create :allocated_claim }

    before do |example|
      updater.update! unless example.metadata[:wait]
    end

    # TODO to be removed post release
    around do |example|
      travel_to(Settings.reject_refuse_messaging_released_at + 1) do
        example.run
      end
    end

    context 'with reasons' do
      let(:params) do
        {
          'state' => 'rejected',
          'state_reason' => %w[wrong_maat_ref no_indictment other],
          'reject_reason_text' => 'rejecting because...',
          'assessment_attributes' => { 'fees' => '', 'expenses' => '0' }
        }
      end

      it 'changes state to rejected' do
        expect(updater.result).to eq :ok
        expect(updater.claim.state).to eq 'rejected'
      end

      it 'adds message to the claim', :wait do
        expect { updater.update! }.to change(claim.messages, :count).by(1)
      end
    end
  end

  context 'refusals' do
    subject(:updater) { described_class.new(claim.id, params.merge(current_user: current_user)) }
    let(:claim) { create :allocated_claim }

    before do |example|
      updater.update! unless example.metadata[:wait]
    end

    # TODO to be removed post release
    around do |example|
      travel_to(Settings.reject_refuse_messaging_released_at + 1) do
        example.run
      end
    end

    context 'with reasons' do
      let(:params) do
        {
          'state' => 'refused',
          'state_reason' => %w[wrong_ia duplicate_claim other_refuse],
          'refuse_reason_text' => 'refusing because...',
          'assessment_attributes' => { 'fees' => '', 'expenses' => '0' }
        }
      end

      it 'changes state to refused' do
        expect(updater.result).to eq :ok
        expect(updater.claim.state).to eq 'refused'
      end

      it 'adds message to the claim', :wait do
        expect { updater.update! }.to change(claim.messages, :count).by(1)
      end
    end
  end

  context 'redeterminations' do
    let(:claim) {
      create(:allocated_claim).tap do |c|
        c.assessment.update(fees: 200.15, expenses: 77.66)
      end
    }

    context 'successful transitions' do
      it 'advances the claim to part authorised' do
        params = { 'state' => 'part_authorised', 'redeterminations_attributes' => { '0' => { 'fees' => '45', 'expenses' => '0.00' } } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :ok
        expect(updater.claim.state).to eq 'part_authorised'
        expect(updater.claim.redeterminations.first.fees).to eq 45.0
        expect(updater.claim.redeterminations.first.expenses).to eq 0.0
        expect(updater.claim.redeterminations.first.disbursements).to eq 0.0
      end

      it 'advances the claim to authorised' do
        params = { 'state' => 'authorised', 'redeterminations_attributes' => { '0' => { 'fees' => '', 'expenses' => '230.00' } } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :ok
        expect(updater.claim.state).to eq 'authorised'
        expect(updater.claim.redeterminations.first.fees.to_f).to eq 0.0
        expect(updater.claim.redeterminations.first.expenses).to eq 230.0
        expect(updater.claim.redeterminations.first.disbursements).to eq 0.0
      end

      it 'advances the claim to refused when no values are supplied' do
        params = { current_user: current_user, 'state' => 'refused', 'state_reason' => ['wrong_ia'] }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :ok
        expect(updater.claim.state).to eq 'refused'
        expect(updater.claim.redeterminations).to be_empty
      end
    end

    context 'errors' do
      it 'errors if assessment data is present in the params but no state specified' do
        params = { 'state' => '', 'redeterminations_attributes' => { '0' => { 'fees' => '128.33', 'expenses' => '42.40' } } }
        updater = described_class.new(claim.id, params).update!
        expect(updater.result).to eq :error
        expect(updater.claim.errors[:determinations]).to include('must select a status')
      end

      context 'when determination values are supplied with refused' do
        it_behaves_like 'an erroneous determination', 'refused', ['must not have values when refusing a claim'], 'assessment'
        it_behaves_like 'an erroneous determination', 'refused', ['must not have values when refusing a claim'], 'redeterminations'
      end

      context 'when determination values are supplied with rejected' do
        it_behaves_like 'an erroneous determination', 'rejected', ['must not have values when rejecting a claim'], 'assessment'
        it_behaves_like 'an erroneous determination', 'rejected', ['must not have values when rejecting a claim'], 'redeterminations'
      end

      context 'when no reasons are supplied with rejected/refused' do
        it_behaves_like 'an erroneous determination', 'rejected', ['requires a reason'], 'redeterminations', [''], '', 0, :rejected_reason
        it_behaves_like 'an erroneous determination', 'refused', ['requires a reason'], 'redeterminations', [''], '', 0, :refused_reason
      end

      context 'when other reason given without reason text' do
        it_behaves_like 'an erroneous determination', 'rejected', ['needs a description'], 'redeterminations', ['other'], 0, 0, :rejected_reason_other
      end

      context 'when reasons given for authorised claims' do
        it_behaves_like 'an erroneous determination', 'authorised', ['must not provide reject/refuse reasons'], 'assessment', ['no_indictment']
        it_behaves_like 'an erroneous determination', 'authorised', ['must not provide reject/refuse reasons'], 'redeterminations', ['wrong_ia']
      end
    end
  end
end

require 'rails_helper'

describe CaseWorkers::ClaimsHelper do
  # before(:each) do
  #   @case_worker = create :case_worker
  #   allow(helper).to receive(:current_user).and_return(@case_worker.user)
  # end

  describe '#current_claims_count' do
    it 'returns a collection of claims in assessment_states for the current user' do
      @case_worker = create(:case_worker)
      allow(helper).to receive(:current_user).and_return(@case_worker.user)
      assessment_claims = double('Current user claims under assessment', count: 22)
      claims = double('Current user claims collection', caseworker_dashboard_under_assessment: assessment_claims)
      expect(@case_worker.user).to receive(:claims).and_return(claims)

      expect(helper.current_claims_count).to eq 22
    end
  end

  describe '#allocated claims count' do
    context 'current user is admin' do
      it 'gets the count for all claims' do
        admin_case_worker = create(:case_worker, :admin)
        allow(helper).to receive(:current_user).and_return(admin_case_worker.user)
        allocated_claims = double('Allocated Claims', count: 42)
        active_claims = double('Active claims', caseworker_dashboard_under_assessment: allocated_claims)
        expect(Claim::BaseClaim).to receive(:active).and_return(active_claims)

        expect(helper.allocated_claims_count).to eq 42
      end
    end
  end

  describe '#unallocated claims count' do
    context 'current user is admin' do
      it 'gets the count for all claims' do
        admin_case_worker = create(:case_worker, :admin)
        allow(helper).to receive(:current_user).and_return(admin_case_worker.user)
        unallocated_claims = double('Unallocated Claims', count: 37)
        active_claims = double('Active claims', submitted_or_redetermination_or_awaiting_written_reasons: unallocated_claims)
        expect(Claim::BaseClaim).to receive(:active).and_return(active_claims)

        expect(helper.unallocated_claims_count).to eq 37
      end
    end
  end

  describe '#completed_claims_count' do
    context 'current user is admin' do
      it 'gets the count for all claims' do
        admin_case_worker = create(:case_worker, :admin)
        allow(helper).to receive(:current_user).and_return(admin_case_worker.user)
        completed_claims = double('Completed Claims', count: 34)
        active_claims = double('Active claims', caseworker_dashboard_completed: completed_claims)
        expect(Claim::BaseClaim).to receive(:active).and_return(active_claims)

        expect(helper.completed_claims_count).to eq 34
      end
    end

    context 'current user is not admin' do
      it 'gets the count for current users claims' do
        case_worker = create(:case_worker)
        completed_claims = double('Completed Claims', count: 71)
        user_claims = double('user claims', caseworker_dashboard_completed: completed_claims)

        allow(helper).to receive(:current_user).and_return(case_worker.user)
        allow(case_worker.user).to receive(:claims).and_return(user_claims)
        expect(helper.completed_claims_count).to eq 71
      end
    end
  end

  context 'carousel helper methods' do
    let(:claim_ids) { [1244, 36364, 3774, 2773, 73773] }

    before do
      allow(helper).to receive_messages(claim_ids:, claim_count: claim_ids.size)
    end

    describe '#claim_position_and_count' do
      it 'returns the position and count of the claim in the list' do
        assign(:claim, double(Claim::BaseClaim, id: 2773))
        expect(helper.claim_position_and_count).to eq '4 of 5'
      end
    end

    describe '#last_claim?' do
      it 'returns true when it is the last claim' do
        assign(:claim, double(Claim::BaseClaim, id: 73773))
        expect(helper.last_claim?).to be true
      end

      it 'returns false when not the last claim' do
        assign(:claim, double(Claim::BaseClaim, id: 3774))
        expect(helper.last_claim?).to be false
      end
    end

    describe '#next_claim_link' do
      it 'returns a link for the next claim id in the series' do
        assign(:claim, double(Claim::BaseClaim, id: 3774))
        expect(helper.next_claim_link('my_text')).to eq(link_to('my_text', case_workers_claim_path(2773)))
      end
    end
  end

  describe 'claim_count' do
    it 'returns the claim count from the session' do
      session[:claim_count] = 3
      expect(helper.claim_count).to eq 3
    end
  end

  describe '#format_miscellaneous_fee_names' do
    subject { format_miscellaneous_fee_names(claim) }

    let(:claim) { create(:claim) }

    before do
      allow(claim).to receive(:eligible_misc_fee_types).and_return(fee_type)
    end

    context 'When there are no eligible fee types' do
      let(:fee_type) { [] }

      it { is_expected.to be_empty }
    end

    context 'When there are brackets in the fee type description' do
      let(:fee_type) do
        [instance_double(Fee::MiscFeeType, description: 'Abuse of process hearings (half day)')]
      end

      it { is_expected.to eq ['Abuse of process hearings'] }
    end

    context 'When there are multiple fee type descriptions of the same fee' do
      let(:fee_type) do
        [
          instance_double(Fee::MiscFeeType, description: 'Abuse of process hearings (half day)'),
          instance_double(Fee::MiscFeeType, description: 'Abuse of process hearings (half day uplift)'),
          instance_double(Fee::MiscFeeType, description: 'Abuse of process hearings (Whole day)'),
          instance_double(Fee::MiscFeeType, description: 'Abuse of process hearings (Whole day uplift)')
        ]
      end

      it { is_expected.to eq ['Abuse of process hearings'] }
    end

    context 'When there are multiple fee type descriptions of different fees' do
      let(:fee_type) do
        [
          instance_double(Fee::MiscFeeType, description: 'Abuse of process hearings (half day)'),
          instance_double(Fee::MiscFeeType, description: 'Abuse of process hearings (half day uplift)'),
          instance_double(Fee::MiscFeeType, description: 'Abuse of process hearings (whole day)'),
          instance_double(Fee::MiscFeeType, description: 'Abuse of process hearings (whole day uplift)'),
          instance_double(Fee::MiscFeeType, description: 'Application to dismiss a charge (half day)'),
          instance_double(Fee::MiscFeeType, description: 'Application to dismiss a charge (half day uplift)'),
          instance_double(Fee::MiscFeeType, description: 'Application to dismiss a charge (whole day)'),
          instance_double(Fee::MiscFeeType, description: 'Application to dismiss a charge (whole day uplift)')
        ]
      end

      it { is_expected.to eq ['Abuse of process hearings', 'Application to dismiss a charge'] }
    end
  end

  describe '#cda_configured?' do
    subject { cda_configured? }

    context 'when COURT_DATA_ADAPTOR_API_UID is set' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('COURT_DATA_ADAPTOR_API_UID').and_return 'test'
      end

      it { is_expected.to be_truthy }
    end

    context 'when COURT_DATA_ADAPTOR_API_UID is not set' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('COURT_DATA_ADAPTOR_API_UID').and_return nil
      end

      it { is_expected.to be_falsey }
    end
  end
end

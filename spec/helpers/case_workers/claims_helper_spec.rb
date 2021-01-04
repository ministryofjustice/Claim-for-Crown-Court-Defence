require 'rails_helper'

describe CaseWorkers::ClaimsHelper do
  # before(:each) do
  #   @case_worker = create :case_worker
  #   allow(helper).to receive(:current_user).and_return(@case_worker.user)
  # end

  describe '#current_claims_count' do
    it 'returns a collection of claims in assessment_states for the current user' do
      @case_worker = create :case_worker
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
        admin_case_worker = create :case_worker, :admin
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
        admin_case_worker = create :case_worker, :admin
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
        admin_case_worker = create :case_worker, :admin
        allow(helper).to receive(:current_user).and_return(admin_case_worker.user)
        completed_claims = double('Completed Claims', count: 34)
        active_claims = double('Active claims', caseworker_dashboard_completed: completed_claims)
        expect(Claim::BaseClaim).to receive(:active).and_return(active_claims)

        expect(helper.completed_claims_count).to eq 34
      end
    end

    context 'current user is  not admin' do
      it 'gets the count for current users claims' do
        case_worker = create :case_worker
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

    before(:each) do
      allow(helper).to receive(:claim_ids).and_return(claim_ids)
      allow(helper).to receive(:claim_count).and_return(claim_ids.size)
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
        expect(helper.next_claim_link('my_text')).to eq (link_to('my_text', case_workers_claim_path(2773)))
      end
    end
  end

  describe 'claim_count' do
    it 'returns the claim count from the session' do
      session[:claim_count] = 3
      expect(helper.claim_count).to eq 3
    end
  end
end

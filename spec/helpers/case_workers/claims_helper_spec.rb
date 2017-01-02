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

end

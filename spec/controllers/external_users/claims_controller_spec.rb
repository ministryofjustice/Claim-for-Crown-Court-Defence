require 'rails_helper'

RSpec.describe ExternalUsers::ClaimsController, type: :controller, focus: true do

  let!(:advocate)       { create(:external_user, :advocate) }
  before { sign_in advocate.user }

  context "list views" do

    let!(:advocate_admin) { create(:external_user, :admin, provider: advocate.provider) }
    let!(:other_advocate) { create(:external_user, :advocate, provider: advocate.provider) }

    let!(:litigator)      { create(:external_user, :litigator) }
    let!(:litigator_admin){ create(:external_user, :litigator_and_admin, provider: litigator.provider) }
    let!(:other_litigator){ create(:external_user, :litigator, provider: litigator.provider) }

    describe '#GET index' do

      it 'returns success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders the template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'assigns the financial summary' do
        get :index
        expect(assigns(:financial_summary)).not_to be_nil
      end

      context 'AGFS claims' do
        before do
          create(:draft_claim, external_user: advocate)
          create(:archived_pending_delete_claim, external_user: advocate)
          create(:draft_claim, external_user: other_advocate)
        end

        context 'advocate' do
          it 'should assign context to claims for the advocate only' do
            get :index
            expect(assigns(:claims_context).map(&:id).sort).to eq(advocate.claims.map(&:id).sort)
          end
          it 'should assign claims to dashboard displayable state claims for the advocate only' do
            get :index
            expect(assigns(:claims)).to eq(advocate.claims.dashboard_displayable_states)
          end
        end

        context 'advocate admin' do
          before { sign_in advocate_admin.user }
          it 'should assign context to claims for the provider' do
            get :index
            expect(assigns(:claims_context).map(&:id).sort).to eq(advocate_admin.provider.claims.map(&:id).sort)
          end
          it 'should assign claims to dashboard displayable state claims for all members of the provder' do
            get :index
            expect(assigns(:claims).map(&:id).sort).to eq(advocate_admin.provider.claims.dashboard_displayable_states.map(&:id).sort)
          end
        end
      end

      context 'LGFS claims' do
        before do
          @draft_claim = create(:litigator_claim, :draft, external_user: litigator, creator: litigator)
          create(:litigator_claim, :archived_pending_delete, external_user: litigator, creator: litigator)
          create(:litigator_claim, :draft, external_user: other_litigator, creator: other_litigator)
        end

        context 'litigator' do
          before { sign_in litigator.user }
          it 'should assign context to claims for the provider' do
            get :index
            expected_claims = Claim::BaseClaim.where(external_user_id: litigator.id).pluck(:id)
            expect(assigns(:claims_context).map(&:id).sort).to eq(expected_claims.sort)
          end

          it 'should assign claims to dashboard displayable state claims for all members of the provder' do
            expected_claims = [ @draft_claim ]
            get :index
            expect(assigns(:claims)).to eq( [ @draft_claim] )
          end
        end

        context 'litigator admin' do
          before { sign_in litigator_admin.user }
          it 'should assign context to claims for the provider' do
            get :index
            expect(assigns(:claims_context)).to eq(litigator_admin.provider.claims)
          end

          it 'should assign claims to dashboard displayable state claims for all members of the provder' do
            get :index
            expect(assigns(:claims)).to eq(litigator_admin.provider.claims_created.dashboard_displayable_states.order('last_submitted_at asc NULLS FIRST, id desc'))
          end
        end
      end

      context 'scheme filtering' do
        before do
          sign_in advocate_admin.user
          get :index, query_params
        end

        context 'ALL filter' do
          let(:query_params) { {scheme: 'all'} }

          it 'should assign context to claims for the provider' do
            expect(assigns(:claims_context)).to eq(advocate_admin.provider.claims_created)
          end
        end

        context 'AGFS filter' do
          let(:query_params) { {scheme: 'agfs'} }

          it 'should assign context to claims for the provider' do
            expect(assigns(:claims_context)).to eq(advocate_admin.provider.claims_created)
          end
        end

        context 'LGFS filter' do
          let(:query_params) { {scheme: 'lgfs'} }

          it 'should assign context to claims for the provider' do
            expect(assigns(:claims_context)).to eq([])
          end
        end
      end

      context 'sorting' do
        let(:query_params) { {} }
        let(:limit) { 10 }

        # This bypass the top-level 'let', making this whole context 10x faster by allowing to create
        # all the needed claims once, in a before(:all) block, and test all the sorting reusing them.
        def advocate
          @advocate ||= create(:external_user, :advocate)
        end

        before(:all) do
          build_sortable_claims_sample(advocate)
        end

        after(:all) do
          clean_database
        end

        before(:each) do
          allow(subject).to receive(:page_size).and_return(limit)
          sign_in advocate.user
          get :index, query_params
        end

        it 'default sorting is claims with draft first (oldest created first) then oldest submitted' do
          expect(assigns(:claims)).to eq(advocate.claims.dashboard_displayable_states.sort('last_submitted_at', 'asc'))
        end

        context 'case number ascending' do
          let(:query_params) { {sort: 'case_number', direction: 'asc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims)).to eq(assigns(:claims).sort_by(&:case_number))
          end
        end

        context 'case number descending' do
          let(:query_params) { {sort: 'case_number', direction: 'desc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims)).to eq(assigns(:claims).sort_by(&:case_number).reverse)
          end
        end

        context 'advocate name ascending' do
          let(:query_params) { {sort: 'advocate', direction: 'asc'} }

          it 'returns ordered claims' do
            returned_names = assigns(:claims).map(&:external_user).map(&:user).map(&:sortable_name)
            expect(returned_names).to eq(returned_names.sort)
          end
        end

        context 'advocate name descending' do
          let(:query_params) { {sort: 'advocate', direction: 'desc'} }

          it 'returns ordered claims' do
            returned_names = assigns(:claims).map(&:external_user).map(&:user).map(&:sortable_name)
            expect(returned_names).to eq(returned_names.sort.reverse)
          end
        end

        context 'claimed amount ascending' do
          let(:query_params) { {sort: 'total_inc_vat', direction: 'asc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims)).to eq(assigns(:claims).sort_by(&:total_including_vat))
          end
        end

        context 'claimed amount descending' do
          let(:query_params) { {sort: 'total_inc_vat', direction: 'desc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims)).to eq(assigns(:claims).sort_by(&:total_including_vat).reverse)
          end
        end

        context 'assessed amount ascending' do
          let(:query_params) { {sort: 'amount_assessed', direction: 'asc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims).map(&:amount_assessed)).to eq(assigns(:claims).sort_by(&:amount_assessed).map(&:amount_assessed))
          end
        end

        context 'assessed amount descending' do
          let(:query_params) { {sort: 'amount_assessed', direction: 'desc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims).map(&:amount_assessed)).to \
              eq(assigns(:claims).sort_by(&:amount_assessed).reverse.map(&:amount_assessed))
          end
        end

        context 'status ascending' do
          let(:query_params) { {sort: 'state', direction: 'asc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims)).to eq(assigns(:claims).sort_by(&:state))
          end
        end

        context 'status descending' do
          let(:query_params) { {sort: 'state', direction: 'desc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims)).to eq(assigns(:claims).sort_by(&:state).reverse)
          end
        end

        context 'date submitted ascending' do
          let(:query_params) { {sort: 'last_submitted_at', direction: 'asc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims)).to eq(assigns(:claims).sort_by{|c| c.last_submitted_at.to_i})
          end
        end

        context 'date submitted descending' do
          let(:query_params) { {sort: 'last_submitted_at', direction: 'desc'} }

          it 'returns ordered claims' do
            expect(assigns(:claims)).to eq(assigns(:claims).sort_by{|c| c.last_submitted_at.to_i}.reverse)
          end
        end

        context 'pagination limit' do
          let(:limit) { 3 }

          it 'paginates to N per page' do
            expect(advocate.claims.dashboard_displayable_states.count).to eq(5)
            expect(assigns(:claims).count).to eq(3)
          end
        end
      end
    end

    describe '#GET archived' do

      it 'returns success' do
        get :archived
        expect(response).to have_http_status(:success)
      end

      it 'renders the template' do
        get :archived
        expect(response).to render_template(:archived)
      end

      context 'AGFS claims' do
        before do
          create(:draft_claim, external_user: advocate)
          create(:archived_pending_delete_claim, external_user: advocate)
          create(:draft_claim, external_user: other_advocate)
        end

        context 'advocate' do
          before { sign_in advocate.user }
          it 'should assign context to provider claims based on external user' do
            get :archived
            expect(assigns(:claims_context).map(&:id).sort).to eq(advocate.claims.map(&:id).sort)
          end
          it 'should assign claims to archived only' do
            get :archived
            expect(assigns(:claims)).to eq(advocate.claims.archived_pending_delete)
          end
        end

        context 'advocate admin' do
          before { sign_in advocate_admin.user }
          it 'should assign context to provider claims based on external user' do
            get :archived
            expect(assigns(:claims_context)).to eq(advocate_admin.provider.claims)
          end
          it 'should assign claims to archived only' do
            get :archived
            expect(assigns(:claims)).to eq(advocate_admin.provider.claims.archived_pending_delete)
          end
        end
      end

      context 'LGFS claims' do
        before do
          create(:litigator_claim, :draft, external_user: litigator, creator: litigator)
          create(:litigator_claim, :archived_pending_delete, external_user: litigator, creator: litigator)
          create(:litigator_claim, :draft, external_user: other_litigator, creator: other_litigator)
        end

        context 'litigator' do
          before { sign_in litigator.user }
          it 'should see same context and claims as a litigator admin' do
            get :archived
            expect(assigns(:claims)).to eq(litigator.provider.claims_created.archived_pending_delete)
          end
        end

        context 'litigator admin' do
          before { sign_in litigator_admin.user }
          it 'should assign context to claims created by all members of the provider' do
            get :archived
            expect(assigns(:claims_context).sort_by{|c| c.id}).to eq(litigator_admin.provider.claims_created.active.sort_by{|c| c.id})
          end
          it 'should retrieve archived state claims only' do
            get :archived
            expect(assigns(:claims).sort_by{|c| c.id}).to eq(litigator_admin.provider.claims_created.active.archived_pending_delete.sort_by{|c| c.id})
          end
        end
      end

      context 'sorting' do
        let(:limit) { 10 }

        before(:each) do
          create_list(:archived_pending_delete_claim, 3, external_user: advocate).each { |c| c.update_column(:last_submitted_at, 8.days.ago) }
          create(:archived_pending_delete_claim, external_user: advocate).update_column(:last_submitted_at, 1.day.ago)
          create(:archived_pending_delete_claim, external_user: advocate).update_column(:last_submitted_at, 2.days.ago)

          allow(subject).to receive(:page_size).and_return(limit)
          get :archived
        end

        it 'orders claims with most recently submitted first' do
          expect(assigns(:claims)).to eq(advocate.claims.archived_pending_delete.sort('last_submitted_at', 'desc'))
        end

        context 'pagination limit' do
          let(:limit) { 3 }

          it 'paginates to N per page' do
            expect(advocate.claims.archived_pending_delete.count).to eq(5)
            expect(assigns(:claims).count).to eq(3)
          end
        end
      end
    end

    describe '#GET outstanding' do
      before(:each) do
        get :outstanding
      end

      it 'returns success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the template' do
        expect(response).to render_template(:outstanding)
      end

      it 'assigns the financial summary' do
        expect(assigns(:financial_summary)).not_to be_nil
      end

      context 'AGFS claims' do
        before do
          create(:submitted_claim, external_user: advocate)
          create(:draft_claim, external_user: advocate)
          create(:archived_pending_delete_claim, external_user: advocate)
        end

        context 'advocate' do
          before { sign_in advocate.user }

          it 'should assign outstanding claims' do
            expect(assigns(:claims)).to match_array(advocate.claims.outstanding)
          end
        end

        context 'advocate admin' do
          before { sign_in advocate_admin.user }

          it 'should assign outstanding claims' do
            expect(assigns(:claims)).to match_array(advocate_admin.provider.claims.outstanding)
          end
        end
      end
    end

    describe '#GET authorised' do
      before(:each) do
        get :authorised
      end

      it 'returns success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the template' do
        expect(response).to render_template(:authorised)
      end

      it 'assigns the financial summary' do
        expect(assigns(:financial_summary)).not_to be_nil
      end

      context 'AGFS claims' do
        before do
          create(:authorised_claim, external_user: advocate)
          create(:part_authorised_claim, external_user: advocate)
          create(:archived_pending_delete_claim, external_user: advocate)
        end

        context 'advocate' do
          before { sign_in advocate.user }

          it 'should assign authorised and part authorised claims' do
            expect(assigns(:claims)).to match_array(advocate.claims.any_authorised)
          end
        end

        context 'advocate admin' do
          before { sign_in advocate_admin.user }

          it 'should assign authorised and part authorised claims' do
            expect(assigns(:claims)).to match_array(advocate_admin.provider.claims.any_authorised)
          end
        end
      end
    end

    describe 'Search' do
      def advocate
        @advocate ||= create(:external_user, :advocate)
      end

      before(:all) do
        @archived_claim = create(:archived_pending_delete_claim, external_user: advocate)
        create(:defendant, claim: @archived_claim, first_name: 'John', last_name: 'Smith')

        @draft_claim = create(:draft_claim, external_user: advocate)
        create(:defendant, claim: @draft_claim, first_name: 'John', last_name: 'Smith')

        @allocated_claim = create(:allocated_claim, external_user: advocate)
        create(:defendant, claim: @allocated_claim, first_name: 'Pete', last_name: 'Adams')
      end

      after(:all) do
        clean_database
      end

      context 'in all claims' do
        context 'by defendant name' do
          it 'finds the claims' do
            get :index, search: 'Smith'
            expect(assigns(:claims)).to eq([@draft_claim])
          end
        end

        context 'by advocate name' do
          it 'finds the claims' do
            get :index, advocate.user.last_name
            expect(assigns(:claims).sort_by(&:state)).to eq([@allocated_claim, @draft_claim])
          end
        end
      end

      context 'in archive' do
        context 'by defendant name' do
          it 'finds the claims' do
            get :archived, search: 'Smith'
            expect(assigns(:claims)).to eq([@archived_claim])
          end
        end

        context 'by advocate name' do
          it 'finds the claims' do
            get :archived, advocate.user.last_name
            expect(assigns(:claims)).to eq([@archived_claim])
          end
        end
      end
    end
  end

  describe "GET #show" do
    subject { create(:claim, external_user: advocate) }

    let(:case_worker) { create(:case_worker) }

    it "returns http success" do
      get :show, id: subject
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claim' do
      get :show, id: subject
      expect(assigns(:claim)).to eq(subject)
    end

    it 'renders the template' do
      get :show, id: subject
      expect(response).to render_template(:show)
    end

    it 'automatically marks unread messages on claim for current user as "read"' do
      create_list(:message, 3, claim_id: subject.id, sender_id: case_worker.user.id)

      expect(subject.unread_messages_for(advocate.user).count).to eq(3)

      get :show, id: subject

      expect(subject.unread_messages_for(advocate.user).count).to eq(0)
    end
  end

  describe 'GET #disc_evidence' do
    before { get :disc_evidence, id: claim }

    let(:claim) { create(:claim, external_user: advocate) }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns the pdf mime type' do
      expect(response.headers['Content-Type']).to eql('application/pdf')
    end
  end

  describe "PATCH #clone_rejected" do
    context 'from rejected claim' do
      subject { create(:rejected_claim, external_user: advocate) }

      before do
        patch :clone_rejected, id: subject
      end

      it 'creates a draft from the rejected claim' do
        expect(Claim::BaseClaim.active.last).to be_draft
        expect(Claim::BaseClaim.active.last.case_number).to eq(subject.case_number)
      end

      it 'redirects to the draft\'s edit page' do
        expect(response).to redirect_to(edit_advocates_claim_path(Claim::BaseClaim.active.last))
      end
    end

    context 'from non-rejected claim' do
      subject { create(:submitted_claim, external_user: advocate) }

      it 'logs the actual error message' do
        expect(LogStuff).to receive(:error).with('ExternalUsers::ClaimsController',
                                                 action: 'clone',
                                                 claim_id: subject.id,
                                                 error: 'Claims::Cloner.clone_rejected_to_new_draft failed with error \'Can only clone claims in state "rejected"\'')
        patch :clone_rejected, id: subject
      end

      describe 'the response' do
        before do
          patch :clone_rejected, id: subject
        end

        it 'redirects to advocates dashboard' do
          expect(response).to redirect_to(external_users_claims_url)
        end

        it 'does not create a draft claim' do
          expect(Claim::BaseClaim.active.last).to_not be_draft
        end

        it'displays a flash error' do
          expect(flash[:alert]).to eq 'An error is preventing this claim from being redrafted.  The problem has been logged and is being investigated. To continue please start a new claim.'
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, id: claim }

    context 'when draft claim' do
      let(:claim) { create(:draft_claim, external_user: advocate) }

      it 'deletes the claim' do
        expect(Claim::BaseClaim.active.count).to eq(0)
      end

      it 'redirects to advocates root url' do
        expect(response).to redirect_to(external_users_claims_url)
        expect(flash[:notice]).to eq 'Claim deleted'
      end
    end

    context 'when non-draft claim in a valid state for archival' do
      let(:claim) { create(:authorised_claim, external_user: advocate) }

      it "sets the claim's state to 'archived_pending_delete'" do
        expect(Claim::BaseClaim.active.count).to eq(1)
        expect(claim.reload.state).to eq 'archived_pending_delete'
        expect(flash[:notice]).to eq 'Claim archived'
      end
    end

    context 'when non-draft claim in an invalid state for archival' do
      let(:claim) { create(:archived_pending_delete_claim, external_user: advocate) }

      it 'responds with an error' do
        expect(Claim::BaseClaim.active.count).to eq(1)
        expect(flash[:alert]).to eq 'This claim cannot be deleted'
      end
    end
  end

  describe "PATCH #unarchive" do
    context 'when archived claim' do
      subject do
        claim = create(:authorised_claim, external_user: advocate)
        claim.archive_pending_delete!
        claim
      end

      before { patch :unarchive, id: subject }

      it 'unarchives the claim and restores to state prior to archiving' do
        expect(subject.reload).to be_authorised
      end

      it 'redirects to external users root url' do
        expect(response).to redirect_to(external_users_claims_url)
      end
    end

    context 'when archived claim has null vat totals' do
      it 'sets the vat totals to zero' do
        # given a claim with nils in vat totals before archiving
        claim = create :authorised_claim, external_user: advocate
        claim.fees_vat = nil
        claim.expenses_vat = nil
        claim.disbursements_vat = nil
        claim.save!
        claim.archive_pending_delete!
        expect(claim.state).to eq 'archived_pending_delete'

        # when I unarchive
        patch :unarchive, id: claim

        # it 'should set the state back to authorised and the totals to zero (not null)'
        claim.reload
        expect(claim.state).to eq 'authorised'
        expect(claim.fees_vat).to eq 0.0
        expect(claim.expenses_vat).to eq 0.0
        expect(claim.disbursements_vat).to eq 0.0
      end
    end

    context 'when non-archived claim' do
      subject { create(:part_authorised_claim, external_user: advocate) }

      before { patch :unarchive, id: subject }

      it 'does not change the claim state' do
        expect(subject).to be_part_authorised
      end

      it 'redirects to external users root url' do
        expect(response).to redirect_to(external_users_claim_url(subject))
      end
    end
  end


  describe 'GET #show_message_controls' do

    let(:claim) { create :refused_claim, external_user: advocate }

    it 'does something' do
      xhr :get, :show_message_controls, id: claim, claim_action: 'Apply for redetermination', format: :js
      expect(response.status).to eq 200
      expect(response).to render_template('shared/show_message_controls')
    end
  end
end

def build_claim_in_state(state)
  claim = FactoryBot.build :unpersisted_claim
  allow(claim).to receive(:state).and_return(state.to_s)
  claim
end

def build_sortable_claims_sample(advocate)
  [:draft, :submitted, :allocated, :authorised, :rejected].each_with_index do |state, i|
    Timecop.freeze(i.days.ago) do
      n = i+1
      claim = create("#{state}_claim".to_sym, external_user: advocate, case_number: "A2016#{(n).to_s.rjust(4,'0')}")
      claim.fees.destroy_all
      claim.expenses.destroy_all

      # cannot stub/mock here so temporarily change state to draft to enable amount calculation of fees
      old_state = claim.state
      claim.state = 'draft'
      create(:misc_fee, claim: claim, quantity: n*1, rate: n*1)
      claim.state = old_state
      claim.assessment.update_values!(claim.fees_total, 0, 0) if claim.authorised?
    end
  end
end

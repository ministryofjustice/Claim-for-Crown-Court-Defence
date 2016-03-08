require 'rails_helper'
require 'support/database_housekeeping'

RSpec.describe CaseWorkers::ClaimsController, type: :controller do
  include DatabaseHousekeeping

  before do
    sign_in @case_worker.user
  end

  context 'non_archive' do

    before(:all) do
      @case_worker = create(:case_worker)
      @claims = []
      10.times do |n|
        Timecop.freeze(n.days.ago) do
          claim = create(:allocated_claim, case_number: "A" + "#{(n+1).to_s.rjust(8,"0")}")
          @claims << claim
        end
      end

      # make the oldest/5th one be resubmitted for redetermination so we can test ordering by last_submitted_at
      # i.e. A00000005 to A00000001 is oldest to most recently CREATED, but A00000005 was LAST_SUBMITTED most recently
      oldest = @claims.last
      oldest.assessment.update(fees: random_amount, expenses: random_amount)
      oldest.authorise!; oldest.redetermine!

      @claims.each { |claim| claim.case_workers << @case_worker }
      @other_claim = create :submitted_claim
    end

    after(:all) do
      clean_database
    end

    

    describe "GET #index" do
      let(:tab) { nil }
      let(:search) { nil }

      before do
        get :index, tab: tab, search: search
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      context 'current claims' do
        it 'shows claims allocated to current user' do
          expect(assigns(:claims)).to match_array(@case_worker.claims.caseworker_dashboard_under_assessment.limit(10))
        end

        it 'defaults ordering of claims to oldest first based on last submitted date' do
          expect(assigns(:claims)).to eq(@case_worker.claims.caseworker_dashboard_under_assessment.order(last_submitted_at: :asc).page(1).per(10))
        end

        it 'paginates to 10 per page' do
          additional_claim = create(:allocated_claim)
          @case_worker.claims << additional_claim
          expect(@case_worker.claims.caseworker_dashboard_under_assessment.count).to eql(11)
          expect(assigns(:claims).count).to eq(10)
          additional_claim.destroy
        end
      end

      context 'search by maat' do
        let(:search) { @case_worker.claims.first.defendants.first.representation_orders.first.maat_reference }

        it 'finds the claims with MAAT reference "12345"' do
          expect(assigns(:claims)).to eq([@case_worker.claims.first])
        end
      end

      context 'search by defendant' do
        let(:search) { @case_worker.claims.first.defendants.first.name }

        it 'finds the claims with specified defendant' do
          expect(assigns(:claims)).to eq([@case_worker.claims.first])
        end
      end

      it 'only includes claims associated with the case worker' do
        expect(assigns(:claims)).to match_array(@claims)
      end

      it 'does not include claim not assigned to case worker' do
        expect(assigns(:claims)).to_not include(@other_claim)
      end

      it 'renders the template' do
        expect(response).to render_template(:index)
      end

    end

    

    describe "GET #show" do
      subject { create(:claim) }

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
        subject.case_workers << @case_worker

        message_1 = create(:message, claim_id: subject.id, sender_id: @case_worker.user.id)
        message_2 = create(:message, claim_id: subject.id, sender_id: @case_worker.user.id)
        message_3 = create(:message, claim_id: subject.id, sender_id: @case_worker.user.id)

        expect(subject.unread_messages_for(@case_worker.user).count).to eq(3)

        get :show, id: subject


        expect(subject.unread_messages_for(@case_worker.user).count).to eq(0)
      end
    end


    describe 'PATCH #update' do
      it 'should update the model' do
        claim = @claims.first
        patch :update, id: claim, claim: { additional_information: 'foo bar' }, commit: 'Update'
        expect(assigns(:claim).additional_information).to eq 'foo bar'
      end
    end
  end

  context "GET #archived" do
    before(:all) do
      @case_worker = create(:case_worker)
      advocate = create :external_user, :advocate
      create_claims(3, :allocated, 'Joex Bloggs', advocate)
      create_claims(1, :allocated, 'Fred Bloggs', advocate)
      create_claims(2, :authorised, 'Joex Bloggs', advocate)
      create_claims(3, :authorised, 'Fred Bloggs', advocate)
      create_claims(1, :part_authorised, 'Fred Bloggs', advocate)
      create_claims(2, :part_authorised, 'Someone Else', advocate)
    end

    after(:all) do
      clean_database
    end

    describe '#archived with no filtering' do
      it 'returns all in authorised  and part authorised statuses' do
        get :archived, 'tab' => 'archived'
        expect(assigns(:claims).size).to eq 8
      end
    end

    describe '#archived with filtering by defendant name' do
      search_terms = {
        'Joex Bloggs' => 2,
        'Fred Bloggs' => 4,
        'Bloggs'      => 6
      }
      search_terms.each do |search_term, expected_number_of_results|
        it 'returns only the claims where the defendant is is in the search terms' do
          get :archived, 'tab' => 'archived', 'search' => search_term
          expect(assigns(:claims).size).to eq expected_number_of_results
        end
      end
    end

    def create_claims(qty, status, defendant_name, advocate)
      factory_name = "#{status}_claim".to_sym
      claims = create_list(factory_name, qty, external_user: advocate)
      claims.each do |claim|
        claim.case_workers << @case_worker
        create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
      end
    end
  end
end
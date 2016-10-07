require 'rails_helper'

RSpec.describe CaseWorkers::ClaimsController, type: :controller do

  before do
    sign_in @case_worker.user
  end

  context 'non_archive' do

    before(:all) do
      @case_worker = create(:case_worker)
      @claims = []
      3.times do |n|
        Timecop.freeze(n.days.ago) do
          claim = create(:draft_claim, case_number: "A" + "#{(n+1).to_s.rjust(8,"0")}")
          create(:misc_fee, claim: claim, quantity: n*1, rate: n*1)
          claim.submit!
          claim.allocate!
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



    describe 'GET #index' do
      let(:query_params) { {} }
      let(:limit) { 10 }

      before do
        allow(subject).to receive(:page_size).and_return(limit)
        get :index, query_params
      end

      context 'default criteria', vcr: {cassette_name: 'spec/case_workers/claims/index'} do
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'shows claims allocated to current user, with default ordering based on last submitted date, oldest first' do
          expect(assigns(:claims).map(&:case_number)).to match_array(@claims.sort_by(&:last_submitted_at).map(&:case_number))
        end

        it 'does not include claim not assigned to case worker' do
          expect(assigns(:claims)).to_not include(@other_claim)
        end

        it 'renders the template' do
          expect(response).to render_template(:index)
        end
      end

      context 'pagination limit', vcr: {cassette_name: 'spec/case_workers/claims/index_pagination'} do
        let(:limit) { 2 }

        it 'paginates to N per page' do
          expect(@claims.size).to eq(3)
          expect(assigns(:claims).size).to eq(2)
        end
      end

      context 'search by case number', vcr: {cassette_name: 'spec/case_workers/claims/index_search_by_case_number'} do
        let(:case_number) { @claims.first.case_number }
        let(:query_params) { { search: case_number } }

        it 'finds the claims matching case number' do
          expect(assigns(:claims).size).to eq(1)
          expect(assigns(:claims).first.case_number).to eq(case_number)
        end
      end

      pending 'TODO: rep orders (needed for maat) not yet implemented in remote response'
      # context 'search by maat', vcr: {cassette_name: 'spec/case_workers/claims/index_search_by_maat'} do
      #   let(:maat) { @claims.first.defendants.first.representation_orders.first.maat_reference }
      #   let(:query_params) { { search: maat } }
      #
      #   it 'finds the claims with MAAT reference "12345"' do
      #     expect(assigns(:claims).size).to eq(1)
      #     expect(assigns(:claims).first.defendants.first.representation_orders.first.maat_reference).to eq(maat)
      #   end
      # end

      context 'search by defendant', vcr: {cassette_name: 'spec/case_workers/claims/index_search_by_defendant'} do
        let(:name) { 'Mya Keeling' }
        let(:query_params) { { search: name } }

        # Ensure the defendant has this name, otherwise VCR will fail.
        # Defendants should really be generated with deterministic names in first place, this is a patch.
        before do
          @claims.first.defendants.first.update_column(:first_name, 'Mya')
          @claims.first.defendants.first.update_column(:last_name, 'Keeling')
        end

        it 'finds the claims with specified defendant' do
          expect(assigns(:claims).size).to eq(1)
          expect(assigns(:claims).first.defendants.first.name).to eq(name)
        end
      end

      describe 'sorting' do
        context 'case number ascending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_case_number_asc'} do
          let(:query_params) { { sort: 'case_number', direction: 'asc' } }

          it 'returns ordered claims' do
            returned_case_numbers = assigns(:claims).map(&:case_number)
            expect(returned_case_numbers).to eq(returned_case_numbers.sort)
          end
        end

        context 'case number descending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_case_number_desc'} do
          let(:query_params) { { sort: 'case_number', direction: 'desc' } }

          it 'returns ordered claims' do
            returned_case_numbers = assigns(:claims).map(&:case_number)
            expect(returned_case_numbers).to eq(returned_case_numbers.sort.reverse)
          end
        end

        context 'advocate name ascending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_advocate_asc'} do
          let(:query_params) { { sort: 'advocate', direction: 'asc' } }

          it 'returns ordered claims' do
            returned_names = assigns(:claims).map(&:external_user).map(&:sortable_name)
            expect(returned_names).to eq(returned_names.sort)
          end
        end

        context 'advocate name descending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_advocate_desc'} do
          let(:query_params) { { sort: 'advocate', direction: 'desc' } }

          it 'returns ordered claims' do
            returned_names = assigns(:claims).map(&:external_user).map(&:sortable_name)
            expect(returned_names).to eq(returned_names.sort.reverse)
          end
        end

        context 'claimed amount ascending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_amount_asc'} do
          let(:query_params) { { sort: 'total_inc_vat', direction: 'asc' } }

          it 'returns ordered claims' do
            returned_amounts = assigns(:claims).map(&:total_including_vat)
            expect(returned_amounts).to eq(returned_amounts.sort)
          end
        end

        context 'claimed amount descending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_amount_desc'} do
          let(:query_params) { { sort: 'total_inc_vat', direction: 'desc' } }

          it 'returns ordered claims' do
            returned_amounts = assigns(:claims).map(&:total_including_vat)
            expect(returned_amounts).to eq(returned_amounts.sort.reverse)
          end
        end

        context 'case type ascending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_casetype_asc'} do
          let(:query_params) { { sort: 'case_type', direction: 'asc' } }

          it 'returns ordered claims' do
            returned_names = assigns(:claims).map(&:case_type).map(&:name)
            expect(returned_names).to eq(returned_names.sort)
          end
        end

        context 'case type descending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_casetype_desc'} do
          let(:query_params) { { sort: 'case_type', direction: 'desc' } }

          it 'returns ordered claims' do
            returned_names = assigns(:claims).map(&:case_type).map(&:name)
            expect(returned_names).to eq(returned_names.sort.reverse)
          end
        end

        context 'date submitted ascending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_date_asc'} do
          let(:query_params) { { sort: 'last_submitted_at', direction: 'asc' } }

          it 'returns ordered claims' do
            returned_dates = assigns(:claims).map(&:last_submitted_at)
            expect(returned_dates).to eq(returned_dates.sort)
          end
        end

        context 'date submitted descending', vcr: {cassette_name: 'spec/case_workers/claims/index_sort_by_date_desc'} do
          let(:query_params) { { sort: 'last_submitted_at', direction: 'desc' } }

          it 'returns ordered claims' do
            returned_dates = assigns(:claims).map(&:last_submitted_at)
            expect(returned_dates).to eq(returned_dates.sort.reverse)
          end
        end
      end
    end



    describe "GET #show" do
      subject { create(:claim) }

      let(:another_case_worker) { create(:case_worker) }

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

        create_list(:message, 3, claim_id: subject.id, sender_id: another_case_worker.user.id)

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

  context 'GET #archived' do
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

    describe '#archived with no filtering', vcr: {cassette_name: 'spec/case_workers/claims/archived'} do
      before(:each) do
        get :archived, 'tab' => 'archived'
      end

      it 'returns all in authorised and part authorised status, with default ordering based on last submitted date, oldest first' do
        expect(assigns(:claims).size).to eq 8
        expect(assigns(:claims).map(&:last_submitted_at)).to eq(assigns(:claims).sort_by(&:last_submitted_at).map(&:last_submitted_at))
      end
    end

    describe '#archived with filtering by defendant name', vcr: {cassette_name: 'spec/case_workers/claims/archived_search_by_defendant'} do
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
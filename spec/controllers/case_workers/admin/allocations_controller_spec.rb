require 'rails_helper'

RSpec.describe CaseWorkers::Admin::AllocationsController, type: :controller do

  before(:all) do

    # create one graduated fee type to match the "real" Trial case type seeded
    create(:graduated_fee_type, code: 'GTRL') #use seeded case types "real" fee type codes
    load "#{Rails.root}/db/seeds/case_types.rb"

    @case_worker = create(:case_worker)
    @admin = create(:case_worker, :admin)
  end

  after(:all) { clean_database }

  before { sign_in @admin.user }

  let(:tab) { nil } # default tab is 'unallocated' when tab not provided

  describe 'GET #new' do
    context 'basic rendering', vcr: {cassette_name: 'spec/case_workers/admin/claims/index'} do
      before(:each) { get :new, tab: tab }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @case_workers' do
        expect(assigns(:case_workers)).not_to be_nil
        expect(assigns(:case_workers).size).to eq(2)
      end

      it 'assigns @allocation' do
        expect(assigns(:allocation)).to be_new_record
      end

      it 'renders the template' do
        expect(response).to render_template(:new)
      end
    end

    describe 'scheme filters' do
      context 'unallocated claims' do
        before(:all) do
          @submitted_agfs_claim = create(:submitted_claim, case_number: 'A11111111')
          @submitted_lgfs_claim = create(:litigator_claim, :submitted, case_number: 'A22222222')
          @allocated_lgfs_claim = create(:litigator_claim, :allocated, case_number: 'A33333333')
        end

        before do
          get :new, params
        end

        after(:all) do
          Claim::BaseClaim.destroy_all
        end

        context 'AGFS claim filter', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_agfs'} do
          let(:params) { {tab: 'unallocated', scheme: 'agfs'} }

          it 'should assign @claims to be only unallocated AGFS claims' do
            expect(assigns(:claims).map(&:case_number)).to match_array([@submitted_agfs_claim.case_number])
          end
        end

        context 'LGFS claim filter', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_lgfs'} do
          let(:params) { {tab: 'unallocated', scheme: 'lgfs'} }

          it 'should assign @claims to be only unallocated LGFS claims' do
            expect(assigns(:claims).map(&:case_number)).to match_array([@submitted_lgfs_claim.case_number])
          end
        end
      end

      context 'allocated claims' do
        before(:all) do
          @allocated_agfs_claim = create(:allocated_claim, case_number: 'A11111111')
          @allocated_lgfs_claim = create(:litigator_claim, :allocated, case_number: 'A22222222')
          @submitted_lgfs_claim = create(:litigator_claim, :submitted, case_number: 'A33333333')
        end

        before do
          get :new, params
        end

        after(:all) do
          Claim::BaseClaim.destroy_all
        end

        context 'AGFS claim filter', vcr: {cassette_name: 'spec/case_workers/admin/claims/allocated_agfs'} do
          let(:params) { {tab: 'allocated', scheme: 'agfs'} }

          it 'should assign @claims to be only allocated AGFS claims' do
            expect(assigns(:claims).map(&:case_number)).to match_array([@allocated_agfs_claim.case_number])
          end
        end

        context 'LGFS claim filter', vcr: {cassette_name: 'spec/case_workers/admin/claims/allocated_lgfs'} do
          let(:params) { {tab: 'allocated', scheme: 'lgfs'} }

          it 'should assign @claims to be only allocated LGFS claims' do
            expect(assigns(:claims).map(&:case_number)).to match_array([@allocated_lgfs_claim.case_number])
          end
        end
      end
    end

    describe 'AGFS case type filters' do
      let(:params) { { tab: 'unallocated', scheme: 'agfs', filter: filter } }

      before do
        get :new, params
      end

      after(:all) do
        Claim::BaseClaim.destroy_all
      end

      context 'fixed_fee', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_agfs/fixed_fee'} do
        let(:filter) { 'fixed_fee' }

        before(:all) do
          @claims = create_filterable_claim(:advocate_claim, :fixed_fee, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'cracked', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_agfs/cracked'} do
        let(:filter) { 'cracked' }

        before(:all) do
          @claims = create_filterable_claim(:advocate_claim, :cracked, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'trial', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_agfs/trial'} do
        let(:filter) { 'trial' }

        before(:all) do
          @claims = create_filterable_claim(:advocate_claim, :trial, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'guilty_plea', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_agfs/guilty_plea'} do
        let(:filter) { 'guilty_plea' }

        before(:all) do
          @claims = create_filterable_claim(:advocate_claim, :guilty_plea, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'redetermination', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_agfs/redetermination'} do
        let(:filter) { 'redetermination' }

        before(:all) do
          @claims = create_filterable_claim(:advocate_claim, :redetermination, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'awaiting_written_reasons', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_agfs/awaiting_written_reasons'} do
        let(:filter) { 'awaiting_written_reasons' }

        before(:all) do
          @claims = create_filterable_claim(:advocate_claim, :awaiting_written_reasons, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end
    end

    describe 'LGFS case type filters' do
      let(:params) { { tab: 'unallocated', scheme: 'lgfs', filter: filter } }

      before do
        get :new, params
      end

      after(:all) do
        Claim::BaseClaim.destroy_all
      end

      context 'fixed_fee', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_lgfs/fixed_fee'} do
        let(:filter) { 'fixed_fee' }

        before(:all) do
          @claims = create_filterable_claim(:litigator_claim, :fixed_fee, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'graduated_fees', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_lgfs/graduated_fees'} do
        let(:filter) { 'graduated_fees' }

        before(:all) do
          @claims = create_filterable_claim(:litigator_claim, :graduated_fees, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'interim_fees', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_lgfs/interim_fees'} do
        let(:filter) { 'interim_fees' }

        before(:all) do
          @claims = create_filterable_claim(:litigator_claim, :interim_fees, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'warrants', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_lgfs/warrants'} do
        let(:filter) { 'warrants' }

        before(:all) do
          @claims = create_filterable_claim(:litigator_claim, :warrants, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'interim_disbursements', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_lgfs/interim_disbursements'} do
        let(:filter) { 'interim_disbursements' }

        before(:all) do
          @claims = create_filterable_claim(:litigator_claim, :interim_disbursements, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'risk_based_bills', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_lgfs/risk_based_bills'} do
        let(:filter) { 'risk_based_bills' }

        before(:all) do
          @claims = create_filterable_claim(:litigator_claim, :risk_based_bills, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'redetermination', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_lgfs/redetermination'} do
        let(:filter) { 'redetermination' }

        before(:all) do
          @claims = create_filterable_claim(:litigator_claim, :redetermination, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end

      context 'awaiting_written_reasons', vcr: {cassette_name: 'spec/case_workers/admin/claims/unallocated_lgfs/awaiting_written_reasons'} do
        let(:filter) { 'awaiting_written_reasons' }

        before(:all) do
          @claims = create_filterable_claim(:litigator_claim, :awaiting_written_reasons, 1)
        end

        it { expect(assigns(:claims).map(&:case_number)).to match_array(@claims.map(&:case_number)) }
      end
    end
  end

  describe 'POST #create' do

    before do
      @case_worker = create(:case_worker)
      @claims = create_list(:submitted_claim, 1)
    end

    context 'when invalid', vcr: {cassette_name: 'spec/case_workers/admin/TODO_allocate_invalid'} do
      before { post :create, allocation: allocation_params }
      let(:allocation_params) {
        {
            claim_ids: @claims.map(&:id)
        }
      }

      it 'does not allocate claims to case worker' do
        expect(@case_worker.claims).to be_empty
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end
    end

    context "allocation", vcr: {cassette_name: 'spec/case_workers/admin/TODO_allocate'} do
      let(:allocation_params) {
        {
            case_worker_id: @case_worker.id,
            claim_ids: @claims.map(&:id)
        }
      }

      context 'when no allocated claims included' do
        before(:each) do
          post :create, allocation: allocation_params, commit: 'Allocate'
        end

        it 'tells the user how many claims were successfully allocated' do
          expect(flash[:notice]).to match /\d claim[s]{0,1} allocated to.*/
        end

        it 'saves audit attributes' do
          transition = @claims.first.last_state_transition
          expect(transition.author_id).to eq(@admin.user.id)
          expect(transition.subject_id).to eq(@case_worker.user.id)
        end

        it 'redirects back to the allocations page' do
          expect(response).to redirect_to(case_workers_admin_allocations_path(tab: :unallocated, scheme: :agfs))
        end
      end

      context 'when already allocated claims included' do
        before(:each) do
          @claims << create(:allocated_claim)
          post :create, allocation: allocation_params, commit: 'Allocate'
        end

        it 'allocates NO claims to case worker' do
          expect(@case_worker.claims).to be_empty
        end

        it 'stores errors for display including header warning' do
          expect(assigns(:allocation).errors.full_messages.size).to eql 2
        end

        it 'renders the new template' do
          expect(response).to render_template(:new)
        end
      end
    end

    context "re-allocation", vcr: {cassette_name: 'spec/case_workers/admin/TODO_reallocate'} do
      let(:allocation_params) {
        {
            case_worker_id: @case_worker.id,
            claim_ids: @claims.map(&:id)
        }
      }

      before(:each) do
        @claims = create_list(:allocated_claim, 1)
        post :create, allocation: allocation_params, tab: 'allocated', commit: 'Re-Allocate'
      end

      it 're-allocates claims to case worker' do
        expect(@case_worker.claims.map(&:id)).to match_array(@claims.map(&:id))
      end

      it 'saves audit attributes' do
        transition = @claims.first.last_state_transition
        expect(transition.author_id).to eq(@admin.user.id)
        expect(transition.subject_id).to eq(@case_worker.user.id)
      end

      it 'redirects back to the re-allocations page' do
        expect(response).to redirect_to(case_workers_admin_allocations_path(tab: :allocated, scheme: :agfs))
      end

      it 'tells the user how many claims were successfully re-allocated' do
        expect(flash[:notice]).to match /\d claim[s]{0,1} allocated to.*/
      end

      it 're-allocates already allocated claims to the case worker' do
        expect(assigns(:allocation).claims.count).to eql 1
        expect(@case_worker.claims.count).to eql 1
      end
    end

  end

  # local helpers
  # --------------
  def create_filterable_claim(factory, filter_type, number)
    for_advocate = factory == :advocate_claim
    for_litigator = factory == :litigator_claim

    attributes = {case_number: 'Z12345678'}

    case filter_type
      # AGFS and LGFS (note: explicit return to avoid continuing)
    when :all
      return create_list(:submitted_claim, number, attributes) if for_advocate
      return create_list(:litigator_claim, :submitted, number, attributes) if for_litigator
    when :fixed_fee
      return create_list(:submitted_claim, number, attributes.merge(case_type_id: CaseType.by_type('Contempt').id)) if for_advocate
      return create_list(:litigator_claim, number, :submitted, attributes.merge(case_type_id: CaseType.by_type('Hearing subsequent to sentence').id)) if for_litigator
    when :redetermination
      return create_list(:redetermination_claim, number, attributes) if for_advocate
      return create_list(:litigator_claim, number, :redetermination, attributes) if for_litigator
    when :awaiting_written_reasons
      return create_list(:awaiting_written_reasons_claim, number, attributes) if for_advocate
      return create_list(:litigator_claim, number, :awaiting_written_reasons, attributes) if for_litigator

      # AGFS only
    when :trial
      create_list(:submitted_claim, number, attributes.merge(case_type_id: CaseType.by_type('Trial').id)) if for_advocate
    when :cracked
      create_list(:submitted_claim, number, attributes.merge(case_type_id: CaseType.by_type('Cracked Trial').id)) if for_advocate
    when :guilty_plea
      create_list(:submitted_claim, number, attributes.merge(case_type_id: CaseType.by_type('Guilty plea').id)) if for_advocate

      # LGFS only
    when :graduated_fees
      create_list(:litigator_claim, number, :submitted, attributes.merge(case_type_id: CaseType.by_type('Trial').id)) if for_litigator
    when :risk_based_bills
      [create(:litigator_claim, :risk_based_bill, attributes.merge(case_type_id: CaseType.by_type('Guilty plea').id))] if for_litigator
    when :interim_fees
      [create(:interim_claim, :interim_effective_pcmh_fee, :submitted, attributes)] if for_litigator
    when :warrants
      [create(:interim_claim, :interim_warrant_fee, :submitted, attributes)] if for_litigator
    when :interim_disbursements
      [create(:interim_claim, :disbursement_only_fee, :submitted, attributes)] if for_litigator
    else
      raise ArgumentError, "invalid filter type specified for \"#{__method__}\""
    end
  end

end

require 'rails_helper'

RSpec.describe CaseWorkers::Admin::AllocationsController, type: :controller do

  before(:all) do

    # create one graduated fee type to match the "real" Trial case type seeded
    create(:graduated_fee_type, code: 'GTRL') #use seeded case types "real" fee type codes
    load "#{Rails.root}/db/seeds/case_types.rb"

    @case_worker = create(:case_worker)
    @admin  = create(:case_worker, :admin)
  end

  after(:all) { clean_database }

  before { sign_in @admin.user }

  let(:tab) { nil }   # default tab is 'unallocated' when tab not provided

  describe 'GET #new' do

    context 'basic rendering' do
      before(:each) { get :new, tab: tab }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @case_workers' do
        expect(assigns(:case_workers)).to eq(CaseWorker.all)
      end

      it 'assigns @allocation' do
        expect(assigns(:allocation)).to be_new_record
      end

      it 'renders the template' do
        expect(response).to render_template(:new)
      end

      context 'allocation tab' do
        render_views
        let(:tab) { 'unallocated' }
        it 'renders the allocation partial' do
          expect(response).to render_template(:partial => '_allocation')
          expect(response).to render_template(:partial => '_scheme_filters')
          expect(response).to render_template(:partial => '_case_type_filters')
        end
      end

      context 're-allocation tab' do
        render_views
        let(:tab) { 'allocated' }
        it 'renders the re-allocation partial' do
          expect(response).to render_template(:partial => '_re_allocation')
          expect(response).to render_template(:partial => '_scheme_filters')
          expect(response).to render_template(:partial => '_search_form')
        end
      end
    end

    context 'allocation' do
      before(:all) do
        @submitted_agfs_claims = create_list(:submitted_claim, 1)
        @allocated_lgfs_claims = create_list(:litigator_claim, 1, :allocated)
        @submitted_lgfs_claims = create_list(:litigator_claim, 1, :submitted)
      end
      after(:all) do
        Claim::BaseClaim.destroy_all
      end

      before { get :new, params }

      context 'AGFS claim filter' do
        let(:params) { { tab: 'unallocated', scheme: 'agfs' } }

        it 'should assign @claims to be only unallocated AGFS claims' do
          expect(assigns(:claims).map(&:id)).to match_array(@submitted_agfs_claims.map(&:id))
        end
      end

      context 'LGFS claim filter' do
        let(:params) { { tab: 'unallocated', scheme: 'lgfs' } }

        it 'should assign @claims to be only unallocated LGFS claims' do
          expect(assigns(:claims).map(&:id)).to match_array(@submitted_lgfs_claims.map(&:id))
        end
      end

      context 'AGFS case type filter' do
        let(:params) { { tab: 'unallocated', scheme: 'agfs', filter: filter } }

        %w{ fixed_fee cracked trial guilty_plea redetermination awaiting_written_reasons }.each do |filter_type|
          context "filter by #{filter_type}" do
            before { @claims = create_filterable_claim(:advocate_claim, "#{filter_type}".to_sym, 1) }
            let(:filter) { "#{filter_type}" }
            it "should assign @claims to be only #{filter_type} type claims" do
              expect(assigns(:claims).map(&:id)).to eql @claims.map(&:id)
            end
          end
        end

        context "fitler by all" do
          let(:filter) { 'all' }
          it "should assign @claims to be all unallocated AGFS claims" do
            expect(assigns(:claims).map(&:id)).to eql @submitted_agfs_claims.map(&:id)
          end
        end
      end

      context 'LGFS case type filter' do
        let(:params) { { tab: 'unallocated', scheme: 'lgfs', filter: filter } }

        %w{ fixed_fee graduated_fees interim_fees warrants interim_disbursements risk_based_bills redetermination awaiting_written_reasons }.each do |filter_type|
          context "filter by #{filter_type}" do

            before do
              @claims = create_filterable_claim(:litigator_claim, "#{filter_type}".to_sym, 1)
              get :new, params
            end
            let(:filter) { "#{filter_type}" }
            it "should assign @claims to be only #{filter_type} type claims" do
              expect(assigns(:claims).map(&:id)).to eql @claims.map(&:id)
            end
          end
        end

        context 'complexities for transfer claims' do
          before do
            # create agfs fixed_fee and graduated_fees to ensure they do not show
            @ff_agfs_claim = create(:advocate_claim, case_type: create(:case_type, :fixed_fee))
            @gf_agfs_claim = create(:advocate_claim, case_type: create(:case_type, :graduated_fee))

            # create lgfs fixed_fee and graduated_fees, expected results
            @gf_claim = create(:transfer_claim, ::graduated_fee_allocation_type)
            @ff_claim = create(:transfer_claim, :fixed_fee_allocation_type)
            get :new, params
          end

          context 'graduated_fees filter' do
            let(:params) { { tab: 'unallocated', scheme: 'lgfs', filter: 'graduated_fees' } }
            it 'should include transfer claims of \'Grad\' allocation type' do
              expect(assigns(:claims).map(&:id)).to eql [@gf_claim.id]
            end
          end

          context 'fixed_fee filter' do
            let(:params) { { tab: 'unallocated', scheme: 'lgfs', filter: 'fixed_fee' } }
            it 'should include transfer claims of \'Fixed\' allocation type' do
              expect(assigns(:claims).map(&:id)).to eql [@ff_claim.id]
            end
          end
        end

        context "fitler by all" do
          let(:filter) { 'all' }
          it "should assign @claims to be all unallocated LGFS claims" do
            expect(assigns(:claims).map(&:id)).to eql @submitted_lgfs_claims.map(&:id)
          end
        end
      end

    end

    context 're-allocation' do
      before(:each) do
        @allocated_agfs_claims = create_list(:allocated_claim, 1)
        @submitted_lfgs_claims = create_list(:litigator_claim, 1, :submitted)
        @allocated_lgfs_claims = create_list(:litigator_claim, 1, :allocated)
      end

      before { get :new, params }

      context 'AGFS claim filter' do
        let(:params) { { tab: 'allocated', scheme: 'agfs' } }

        it 'should assign @claims to be only allocated AGFS claims' do
          expect(assigns(:claims).map(&:id)).to match_array(@allocated_agfs_claims.map(&:id))
        end
      end

      context 'LGFS claim filter' do
        let(:params) { { tab: 'allocated', scheme: 'lgfs' } }

        it 'should assign @claims to be only allocated LGFS claims' do
          expect(assigns(:claims).map(&:id)).to match_array(@allocated_lgfs_claims.map(&:id))
        end
      end
    end

  end

  describe 'POST #create' do

    before do
      @case_worker = create(:case_worker)
      @claims = create_list(:submitted_claim, 1)
    end

    context 'when invalid' do
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

    context "allocation" do
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

        it 'renders the new template' do
          expect(response).to render_template(:new)
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

    context "re-allocation" do
      let(:allocation_params) {
        {
          case_worker_id: @case_worker.id,
          claim_ids: @claims.map(&:id)
        }
      }

      before(:each) do
        @claims = create_list(:allocated_claim, 1)
        post :create, allocation: allocation_params, commit: 'Re-Allocate'
      end

      it 're-allocates claims to case worker' do
        expect(@case_worker.claims.map(&:id)).to match_array(@claims.map(&:id))
      end

      it 'renders new allocation template' do
        expect(response).to render_template :new
      end

      it 'tells the user how many claims were successfully re-allocated' do
        expect(flash[:notice]).to match /\d claim[s]{0,1} allocated to.*/
      end

      it 're-allocates already allocated claims to the case worker' do
        expect(assigns(:allocation).claims.count).to eql 1
        expect(@case_worker.claims.count).to eql 1
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end
    end

  end

  # local helpers
  # --------------
  def create_filterable_claim(factory, filter_type, number)
    for_advocate = factory == :advocate_claim
    for_litigator = factory == :litigator_claim

    case filter_type
      # AGFS and LGFS (note: explicit return to avoid continuing)
      when :all
        return create_list(:submitted_claim, number) if for_advocate
        return create_list(:litigator_claim, :submitted, number) if for_litigator
      when :fixed_fee
        return create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Contempt').id) if for_advocate
        return create_list(:litigator_claim, number, :submitted, case_type_id: CaseType.by_type('Hearing subsequent to sentence').id) if for_litigator
      when :redetermination
        return create_list(:redetermination_claim, number) if for_advocate
        return create_list(:litigator_claim, number, :redetermination) if for_litigator
      when :awaiting_written_reasons
        return create_list(:awaiting_written_reasons_claim, number) if for_advocate
        return create_list(:litigator_claim, number, :awaiting_written_reasons) if for_litigator

      # AGFS only
      when :trial
        create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Trial').id) if for_advocate
      when :cracked
        create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Cracked Trial').id) if for_advocate
      when :guilty_plea
        create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Guilty plea').id) if for_advocate

      # LGFS only
      when :graduated_fees
        create_list(:litigator_claim, number, :submitted, case_type_id: CaseType.by_type('Trial').id) if for_litigator
      when :risk_based_bills
        [create(:litigator_claim, :risk_based_bill, case_type_id: CaseType.by_type('Guilty plea').id )] if for_litigator
      when :interim_fees
        [create(:interim_claim, :interim_fee)] if for_litigator
      when :warrants
        [create(:interim_claim, :warrant_fee)] if for_litigator
      when :interim_disbursements
        [create(:interim_claim, :disbursement_only_fee)] if for_litigator
      else
        raise ArgumentError, "invalid filter type specified for \"#{__method__}\""
    end
  end

end

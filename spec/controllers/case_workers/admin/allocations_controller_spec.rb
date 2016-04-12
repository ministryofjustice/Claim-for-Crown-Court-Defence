require 'rails_helper'

RSpec.describe CaseWorkers::Admin::AllocationsController, type: :controller do
  include DatabaseHousekeeping

  before(:all) do
    load "#{Rails.root}/db/seeds/case_types.rb"
    @case_worker = create(:case_worker)
    @admin  = create(:case_worker, :admin)
  end

  after(:all) { clean_database }

  before { sign_in @admin.user }

  let(:tab) { nil }   # default tab is 'unallocated' when tab not provided

  describe 'GET #new' do

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
        expect(response).to render_template(:partial => '_search')
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

      context 'Case type filter' do
        let(:params) { { tab: 'unallocated', scheme: 'agfs', filter: filter } }

        %w{ fixed_fee cracked trial guilty_plea redetermination awaiting_written_reasons }.each do |filter_type|
          context "filter by #{filter_type}" do
            before { @claims = create_filterable_claim("#{filter_type}".to_sym, 1) }
            let(:filter) { "#{filter_type}" }
            it "should assign @claims to be only #{filter_type} type claims" do
              expect(assigns(:claims).map(&:id)).to eql @claims.map(&:id)
            end
          end
        end

        context "fitler by all" do
          let(:filter) { 'all' }
          it "should assign @claims to be all unallocated agfs claims" do
            expect(assigns(:claims).map(&:id)).to eql @submitted_agfs_claims.map(&:id)
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
  def create_filterable_claim(filter_type, number)
   case filter_type
      when :all
        create_list(:submitted_claim, number)
      when :fixed_fee
        create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Contempt').id)
      when :trial
        create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Trial').id)
      when :cracked
        create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Cracked Trial').id)
      when :guilty_plea
        create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Guilty plea').id)
      when :redetermination
        create_list(:redetermination_claim, number)
      when :awaiting_written_reasons
        create_list(:awaiting_written_reasons_claim, number)
    end
  end

end

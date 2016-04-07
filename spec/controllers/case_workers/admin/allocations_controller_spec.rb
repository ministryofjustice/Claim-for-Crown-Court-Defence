require 'rails_helper'

RSpec.describe CaseWorkers::Admin::AllocationsController, type: :controller do
  include DatabaseHousekeeping

  before(:all) do
    @admin  = create(:case_worker, :admin)
    @claims = create_list(:submitted_claim, 2)
    @allocated_claims = create_list(:allocated_claim, 2)
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

      it 'assigns @claims' do
        expect(assigns(:claims)).to eq(@claims)
      end

      it 'renders the allocation partial' do
        expect(response).to render_template(:partial => '_allocation')
      end
    end

    context 're-allocation tab' do
      render_views

      let(:tab) { 'allocated' }

      it 'assigns @claims' do
        expect(assigns(:claims)).to eq(@allocated_claims)
      end

      it 'renders the re-allocation partial' do
        expect(response).to render_template(:partial => '_re_allocation')
      end
    end
  end

  describe 'POST #create' do

    context 'when invalid' do
      before { post :create, allocation: allocation_params }
      let(:allocation_params) {
        {
          claim_ids: @claims.map(&:id)
        }
      }

      before(:all) do
        @case_worker = create(:case_worker)
      end

      it 'does not allocate claims to case worker' do
        expect(@case_worker.claims).to be_empty
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end
    end


    context "allocation" do

      before(:all) do
        @case_worker = create(:case_worker)
        @claims << create(:allocated_claim)
      end

      let(:allocation_params) {
        {
          case_worker_id: @case_worker.id,
          claim_ids: @claims.map(&:id)
        }
      }

      before(:each) { post :create, allocation: allocation_params, commit: 'Allocate' }

      it 'allocates only unallocated claims to case worker' do
        expect(@case_worker.claims).to match_array(@claims[0..1])
      end

      it 'renders new allocation template' do
        expect(response).to render_template :new
      end

      it 'tells the user how many claims were successfully allocated' do
        expect(flash[:notice]).to have_content('2 claims allocated to')
      end

      it 'stores errors for display' do
        expect(assigns(:allocation).errors.full_messages.size).to eql 1
        expect(assigns(:allocation).errors.full_messages.first).to match /Claim.*already.*allocated/
      end

      it 'does not allocate already allocated claims to the case worker' do
        expect(assigns(:allocation).claims.count).to eql 3
        expect(@case_worker.claims.count).to eql 2
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end

    end

    context "re-allocation" do

      before(:all) do
        @case_worker = create(:case_worker)
        @claims = create_list(:allocated_claim, 2)
      end

      before(:each) { post :create, allocation: allocation_params, commit: 'Re-Allocate' }

      let(:allocation_params) {
        {
          case_worker_id: @case_worker.id,
          claim_ids: @claims.map(&:id)
        }
      }

      it 're-allocates claims to case worker' do
        expect(@case_worker.claims).to match_array(@claims)
      end

      it 'renders new allocation template' do
        expect(response).to render_template :new
      end

      it 'tells the user that it was successful and the number of claims re-allocated' do
        expect(flash[:notice]).to have_content('2 claims allocated to')
      end

      it 're-allocates already allocated claims to the case worker' do
        expect(assigns(:allocation).claims.count).to eql 2
        expect(@case_worker.claims.count).to eql 2
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end

    end

  end
end

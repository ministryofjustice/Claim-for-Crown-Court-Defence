require 'rails_helper'

RSpec.describe CaseWorkers::Admin::AllocationsController, type: :controller do
  before(:all) do
    # create(:graduated_fee_type, code: 'GTRL') #use seeded case types 'real' fee type codes
    # load '#{Rails.root}/db/seeds/case_types.rb'
    @case_worker = create(:case_worker)
    @admin = create(:case_worker, :admin)
  end

  after(:all) { clean_database }

  before(:each) { sign_in @admin.user }

  let(:tab) { nil } # default tab is 'unallocated' when tab not provided

  let(:mock_claim_1) { double('MockClaim', id: 1) }
  let(:mock_claim_2) { double('MockClaim', id: 2) }

  let(:claims_collection) { double('claims collection', remote?: true, first: [mock_claim_1, mock_claim_2]) }

  let(:paginated_collection) { double(Remote::Collections::PaginatedCollection, claims: claims_collection) }

  let(:standard_allocation_params) do
    {
      sorting: 'last_submitted_at',
      direction: 'asc',
      scheme: 'agfs',
      filter: 'all',
      page: 0,
      limit: 25,
      search: nil,
      value_band_id: 0
    }
  end

  let(:create_allocation_params) do
    {
      tab: 'unallocated',
      allocation: {
        case_worker_id: '75',
        claim_ids: ['4', '']
      },
      commit: 'Allocate',
      controller: 'case_workers/admin/allocations',
      action: 'create'
    }
  end

  let(:deallocation_params) do
    {
      tab: 'allocated',
      scheme: '',
      page: '',
      allocation: {
        deallocate: 'true',
        case_worker_id: '',
        claim_ids: ['3', '4', '']
      },
      commit: 'Re-allocate',
      controller: 'case_workers/admin/allocations',
      action: 'create'
    }
  end

  describe 'POST #create' do
    let(:case_worker_service_instance) { double CaseWorkerService, active: 'case_worker_collection' }
    let(:case_worker_claims_instance) { double Claims::CaseWorkerClaims, claims: claims_collection }
    let(:claims_collection) { double  Remote::Claim, remote?: true, first: double('page of claims', map: [1, 3, 4]) }
    let(:allocation) { double Allocation, successful_claims: 'successful_claims_collection', case_worker: @case_worker }

    let(:expected_params) do
      {
        'case_worker_id' => '75',
        'claim_ids' => ['4', ''],
        'allocating' => true
      }
    end

    let(:expected_params_with_user) do
      {
        'case_worker_id' => '75',
        'claim_ids' => ['4', ''],
        'allocating' => true,
        'current_user' => @admin.user
      }
    end

    before(:each) do
      expect(CaseWorkerService).to receive(:new).and_return(case_worker_service_instance)
      expect(Claims::CaseWorkerClaims).to receive(:new).and_return(case_worker_claims_instance)
      expect(Allocation).to receive(:new).with(strong_params(expected_params))
      expect(Allocation).to receive(:new).with(strong_params(expected_params_with_user)).and_return(allocation)
    end

    context 'success' do
      it 'redirects to allocation page' do
        expect(allocation).to receive(:save).and_return(true)
        post :create, params: create_allocation_params
        expect(response).to redirect_to(case_workers_admin_allocations_path(tab: 'unallocated', scheme: 'agfs'))
      end
    end

    context 'failure' do
      it 'renders new' do
        expect(allocation).to receive(:save).and_return(false)
        post :create, params: create_allocation_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #new' do
    it 'calls the Caseworker service and Claims::CaseWorkerClaims services' do
      case_worker_service = double CaseWorkerService
      active_case_workers = double 'active case workers'
      expect(CaseWorkerService).to receive(:new).with(current_user: @admin.user).and_return(case_worker_service)
      expect(case_worker_service).to receive(:active).and_return(active_case_workers)

      claims_service = double Claims::CaseWorkerClaims
      expect(Claims::CaseWorkerClaims).to receive(:new).with(current_user: @admin.user, action: 'unallocated', criteria: standard_allocation_params).and_return(claims_service)
      expect(claims_service).to receive(:claims).and_return(claims_collection)

      get :new, params: { tab: tab }

      expect(assigns(:case_workers)).to eq active_case_workers
      expect(assigns(:claims)).to eq claims_collection
    end
  end
end

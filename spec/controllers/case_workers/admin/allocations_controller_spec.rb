require 'rails_helper'

RSpec.describe CaseWorkers::Admin::AllocationsController, type: :controller do




  before(:all) do
    # create(:graduated_fee_type, code: 'GTRL') #use seeded case types "real" fee type codes
    # load "#{Rails.root}/db/seeds/case_types.rb"
    @case_worker = create(:case_worker)
    @admin = create(:case_worker, :admin)
  end

  after(:all) { clean_database }

  before(:each) { sign_in @admin.user }

  let(:tab) { nil } # default tab is 'unallocated' when tab not provided

  let(:mock_claim_1) { double('MockClaim', id: 1) }
  let(:mock_claim_2) { double('MockClaim', id: 2) }

  let(:claims_collection) { double('claims collection', remote?: true, first: [ mock_claim_1, mock_claim_2 ] ) }

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


  describe 'GET #new' do
    it 'calls the Caseworker service and Claims::CaseWorkerClaims services' do
      case_worker_service = double CaseWorkerService
      active_case_workers = double 'active case workers'
      expect(CaseWorkerService).to receive(:new).with(current_user: @admin.user).and_return(case_worker_service)
      expect(case_worker_service).to receive(:active).and_return(active_case_workers)

      claims_service = double Claims::CaseWorkerClaims
      expect(Claims::CaseWorkerClaims).to receive(:new).with(current_user: @admin.user, action: 'unallocated', criteria: standard_allocation_params).and_return(claims_service)
      expect(claims_service).to receive(:claims).and_return(claims_collection)

      get :new, tab: tab

      expect(assigns(:case_workers)).to eq active_case_workers
      expect(assigns(:claims)).to eq claims_collection
    end
  end
end

require 'rails_helper'
require 'spec_helper'
require 'api_spec_helper'
require 'support/claim_api_endpoints'

describe API::V2::CaseWorkers::Claim do
  include Rack::Test::Methods
  include ApiSpecHelper

  after(:all) { clean_database }

  let(:get_claims_endpoint) { '/api/case_workers/claims' }
  let(:case_worker) { create(:case_worker) }
  let(:pagination) { {} }
  let(:params) do
    {
      api_key: case_worker.user.api_key
    }.merge(pagination)
  end

  def do_request
    get get_claims_endpoint, params, format: :json
  end

  describe 'GET claims' do
    it 'should return 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v1'

      do_request
      expect(last_response.status).to eq 406
      expect(last_response.body).to include('The requested version is not supported.')
    end

    it 'should require an API key' do
      params.delete(:api_key)

      do_request
      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Unauthorised')
    end

    it 'should return a JSON with the required information' do
      response = do_request
      expect(response.status).to eq 200
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:pagination)
      expect(body).to have_key(:items)
    end

    context 'filtering the correct dataset' do
      it 'selects the correct data' do
        @graduated_fee_type = create :graduated_fee_type
        @ct_ff = create :case_type, :fixed_fee
        @ct_gf = create :case_type, :graduated_fee, fee_type_code: @graduated_fee_type.unique_code
        @lgfs_sub_ff_vb10 = create_lgfs_submitted_fixed_fee
        @lgfs_sub_ff_vb20 = create_lgfs_submitted_fixed_fee_vb20
        @lgfs_sub_gf_vb10 = create_lgfs_submitted_grad_fee
        @lgfs_sub_gf_vb30 = create_lgfs_submitted_grad_fee_vb30


        puts "Claim created #{@lgfs_sub_gf_vb30.id}"
        ap Claim::LitigatorClaim.graduated_fees.map(&:id)
        puts ">>>>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
        ap Claim::LitigatorClaim.graduated_fees.value_band(30).map(&:id)
        print_totals(@lgfs_sub_gf_vb30)
      end


      def create_lgfs_submitted_fixed_fee
        create :litigator_claim, :submitted, case_type: @ct_ff
      end

      def create_lgfs_submitted_fixed_fee_vb20
        claim = create_lgfs_submitted_fixed_fee
        create(:fixed_fee, :lgfs, claim: claim, amount: 25_000.0)
        claim.save!
        claim
      end

      def create_lgfs_submitted_grad_fee
        create :litigator_claim, :submitted, :graduated_fee
      end

      def create_lgfs_submitted_grad_fee_vb30
        claim = create_lgfs_submitted_grad_fee
        create(:graduated_fee, claim: claim, amount: 125_000.0)
        claim.save!
        claim
      end


      def print_totals(claim)
        puts "Claim gross total: #{gross_total(claim)}"
        puts "Claim net total:   #{claim.total}"
        puts "Expenses:          #{claim.expenses_total}"
        puts "Disbursements:     #{claim.disbursements_total}"
        puts "Fees:              #{claim.fees_total}"
      end

      def gross_total(claim)
        claim.total + claim.vat_amount
      end
    end
  end


  context 'pagination' do
    def pagination_details(response)
      JSON.parse(response.body, symbolize_names: true).fetch(:pagination)
    end

    context 'default' do
      it 'should paginate with default values' do
        pagination = pagination_details(do_request)
        expect(pagination.sort.to_h).to eq({current_page: 1, limit_value: 10, total_count: 0, total_pages: 0})
      end
    end
  end

    context 'custom values' do
      let(:pagination) { { limit: 5, page: 3 } }

      it 'should paginate with default values' do
        pagination = pagination_details(do_request)
        expect(pagination.sort.to_h).to eq({current_page: 3, limit_value: 5, total_count: 0, total_pages: 0})
      end
    end
end

require 'rails_helper'

RSpec.describe API::V2::Search do
  include Rack::Test::Methods
  include ApiSpecHelper
  include DatabaseHousekeeping

  before(:all) do
    create(:deterministic_claim, :redetermination) do |claim|
      create(:injection_attempt, :with_errors, claim:)
    end
  end

  after(:all) { clean_database }

  let(:get_claims_endpoint) { '/api/search/unallocated' }
  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:l33t_h4xx0r) { create(:external_user) }
  let(:api_key) { case_worker_admin.user.api_key }
  let(:params) { { api_key:, scheme: 'agfs' } }
  let(:search_keys) {
    %i[
      id
      uuid
      scheme
      scheme_type
      case_number
      state
      state_display
      court_name
      case_type
      total
      total_display
      external_user
      last_submitted_at
      last_submitted_at_display
      defendants
      maat_references
      injection_errors
      filter
    ]
  }
  let(:search_filter_keys) {
    %i[
      disk_evidence
      redetermination
      fixed_fee
      awaiting_written_reasons
      cracked
      trial
      guilty_plea
      graduated_fees
      interim_fees
      agfs_warrants
      lgfs_warrants
      interim_disbursements
      risk_based_bills
      injection_errored
      cav_warning
      additional_prep_fee_warning
      agfs_hardship
      clar_fees_warning
      lgfs_hardship
      supplementary
    ]
  }

  def do_request
    get get_claims_endpoint, params, format: :json
  end

  describe 'GET unallocated' do
    it 'returns 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v1'

      do_request
      expect(last_response.status).to eq 406
      expect(last_response.body).to include('The requested version is not supported.')
    end

    it 'requires an API key' do
      params.delete(:api_key)

      do_request
      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Unauthorised')
    end

    context 'when accessed by a CaseWorker' do
      let(:result_data) { JSON.parse(last_response.body, symbolize_names: true).first }

      before { do_request }

      it 'returns success' do
        expect(last_response).to be_ok
      end

      it { expect(result_data.keys).to match_array(search_keys) }
      it { expect(result_data[:filter].keys).to match_array(search_filter_keys) }

      it 'returns JSON with expected injection error message' do
        search_result = JSON.parse(last_response.body, symbolize_names: true).first
        expect(search_result[:injection_errors]).to eql 'Claim not injected'
      end

      it 'returns a single claims' do
        search_result = JSON.parse(last_response.body, symbolize_names: true).count
        expect(search_result).to eq 1
      end

      context 'filtered by LGFS' do
        let(:params) { { api_key:, scheme: 'lgfs' } }

        it 'returns no claims' do
          search_result = JSON.parse(last_response.body, symbolize_names: true).count
          expect(search_result).to eq 0
        end
      end
    end

    context 'when accessed by a ExternalUser' do
      before { do_request }

      let(:api_key) { l33t_h4xx0r.user.api_key }

      it 'returns unauthorised' do
        expect(last_response).to be_unauthorized
        expect(last_response.body).to include('Unauthorised')
      end
    end
  end
end

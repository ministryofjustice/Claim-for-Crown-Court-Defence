require 'rails_helper'
require 'spec_helper'
require 'api_spec_helper'
require 'support/claim_api_endpoints'

describe API::V2::Search do
  include Rack::Test::Methods
  include ApiSpecHelper
  include DatabaseHousekeeping

  before(:all) do
    create(:deterministic_claim, :redetermination)
  end

  after(:all) { clean_database }

  let(:get_claims_endpoint) { '/api/search/unallocated' }
  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:pagination) { {} }
  let(:params) do
    {
        api_key: case_worker_admin.user.api_key,
        scheme: 'agfs'
    }
  end

  def do_request
    get get_claims_endpoint, params, format: :json
  end

  describe 'GET unallocated' do
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
      cw = body.first

      expect(cw.keys).to eq([:id, :uuid, :scheme, :scheme_type, :case_number, :state, :state_display, :court_name, :case_type, :total, :total_display, :external_user, :last_submitted_at, :last_submitted_at_display, :defendants, :maat_references, :filter])
    end
  end
end

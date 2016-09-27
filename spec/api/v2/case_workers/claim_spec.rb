require 'rails_helper'
require 'spec_helper'
require 'api_spec_helper'
require 'support/claim_api_endpoints'

describe API::V2::CaseWorkers::Claim do
  include Rack::Test::Methods
  include ApiSpecHelper

  after(:all) { clean_database }

  let(:get_claims_endpoint) { '/api/case_workers/claims' }
  let(:params) { {} }

  describe 'GET claims' do
    it 'should return 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v1'

      get get_claims_endpoint, params, format: :json
      expect(last_response.status).to eq 406
      expect(last_response.body).to include('The requested version is not supported.')
    end

    # TODO: implement API key validation
    xit 'should require an API key' do
      params.delete(:api_key)
      get get_claims_endpoint, params, format: :json
      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Unauthorised')
    end

    # TODO: implement endpoint
    xit 'should return a JSON formatted list of the required information' do
      response = get get_claims_endpoint, params, format: :json
      expect(response.status).to eq 200
    end
  end
end

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

      context 'custom values' do
        let(:pagination) { { limit: 5, page: 3 } }

        it 'should paginate with default values' do
          pagination = pagination_details(do_request)
          expect(pagination.sort.to_h).to eq({current_page: 3, limit_value: 5, total_count: 0, total_pages: 0})
        end
      end
    end
  end
end

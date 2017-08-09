require 'rails_helper'
require 'spec_helper'
require 'api_spec_helper'

RSpec::Matchers.define :be_valid_ccr_claim_json do
  match do |response|
    schema_path = ClaimJsonSchemaValidator::CCR_SCHEMA_FILE
    @errors = JSON::Validator.fully_validate(schema_path, response.body)
    @errors.empty?
  end

  description do
    "be valid ccr claim json"
  end

  failure_message do |response|
    spacer = "\s" * 2
    "expected JSON to be valid against CCR formatted claim schema but the following errors were raised:\n" +
    @errors.each_with_index.map { |error, idx| "#{spacer}#{idx+1}. #{error}"}.join("\n")
  end
end

describe API::V2::CCRClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  after(:all) { clean_database }

  before(:all) do
    @case_worker = create(:case_worker, :admin)
    @claim = create(:authorised_claim)
  end

  def do_request(claim_uuid: @claim.uuid, api_key: @case_worker.user.api_key)
    get "/api/ccr/claims/#{claim_uuid}", {api_key: api_key}, {format: :json}
  end

  describe 'GET /ccr/claim/:uuid' do
    it 'should return 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v1'

      do_request
      expect(last_response.status).to eq 406
      expect(last_response.body).to include('The requested version is not supported.')
    end

    it 'should require an API key' do
      do_request(api_key: nil)
      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Unauthorised')
    end

    context 'claim not found' do
      it 'should respond not found when claim is not found' do
        do_request(claim_uuid: '123-456-789')
        expect(last_response.status).to eq 404
        expect(last_response.body).to include('Claim not found')
      end
    end

    context 'should return CCR compatible JSON' do
      subject(:response) { do_request }

      before do
        allow_any_instance_of(CaseType).to receive(:bill_scenario).and_return 'AS000004'
      end

      it 'returned JSON should be valid against JSON schema' do
        expect(response).to be_valid_ccr_claim_json
      end

    end
  end
end

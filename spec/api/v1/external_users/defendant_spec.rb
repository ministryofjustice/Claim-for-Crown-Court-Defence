require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Defendant do
  include Rack::Test::Methods
  include ApiSpecHelper

  ALL_DEFENDANT_ENDPOINTS = [endpoint(:defendants, :validate), endpoint(:defendants)]
  FORBIDDEN_DEFENDANT_VERBS = [:get, :put, :patch, :delete]

  # NOTE: need to specify claim.source as api to ensure defendant model validations applied
  let!(:provider)      { create(:provider) }
  let!(:claim)         { create(:claim, source: 'api').reload }
  let!(:valid_params)  { { api_key: provider.api_key, claim_id: claim.uuid, first_name: 'JohnAPI', last_name: 'SmithAPI', date_of_birth: '1980-05-10' } }

  let(:json_error_response) do
    [
      { 'error' => 'Enter a date of birth for the defendant' },
      { 'error' => 'Enter a first name for the defendant' },
      { 'error' => 'Enter a last name for the defendant' }
    ].to_json
  end

  context 'when sending non-permitted verbs' do
    ALL_DEFENDANT_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_DEFENDANT_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe "POST #{endpoint(:defendants)}" do
    def post_to_create_endpoint
      post endpoint(:defendants), valid_params, format: :json
    end

    include_examples 'should NOT be able to amend a non-draft claim'

    context 'when defendant params are valid' do
      it 'should create defendant, return 201 and defendant JSON output including UUID' do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(Defendant.find_by(uuid: json['id']).uuid).to eq(json['id'])
      end

      it 'should exclude API key from response' do
        post_to_create_endpoint
        expect(last_response.status).to eq(201)
        json = JSON.parse(last_response.body)
        expect(json['api_key']).to be_nil
      end

      it 'should create one new defendant' do
        expect { post_to_create_endpoint }.to change { Defendant.count }.by(1)
      end

      it 'should create a new record using the params provided' do
        post_to_create_endpoint
        new_defendant = Defendant.last
        expect(new_defendant.claim_id).to eq claim.id
        expect(new_defendant.first_name).to eq valid_params[:first_name]
        expect(new_defendant.last_name).to eq valid_params[:last_name]
        expect(new_defendant.date_of_birth).to eq valid_params[:date_of_birth].to_date
      end
    end

    context 'when defendant params are invalid' do
      context 'invalid API key' do
        include_examples 'invalid API key create endpoint', exclude: :other_provider
      end

      context 'missing expected params' do
        it 'should return a JSON error array with required model attributes' do
          [:first_name,:last_name,:date_of_birth].each { |k| valid_params.delete(k) }
          post_to_create_endpoint
          expect(last_response.status).to eq 400
          expect(last_response.body).to eq(json_error_response)
        end
      end

      context 'malformed claim UUID' do
        it 'rejects malformed uuids' do
          valid_params[:claim_id] = 'any-old-rubbish'
          post_to_create_endpoint
          expect_error_response('Claim cannot be blank')
        end
      end
    end
  end

  describe "POST #{endpoint(:defendants, :validate)}" do
    def post_to_validate_endpoint
      post endpoint(:defendants, :validate), valid_params, format: :json
    end

    include_examples 'invalid API key validate endpoint', exclude: :other_provider

    it 'valid requests should return 200 and String true' do
      post_to_validate_endpoint
      expect_validate_success_response
    end

    it 'missing required params should return 400 and a JSON error array' do
      [:first_name,:last_name,:date_of_birth].each { |k| valid_params.delete(k) }
      post_to_validate_endpoint
      expect(last_response.status).to eq 400
      expect(last_response.body).to eq(json_error_response)
    end

    it 'invalid claim id should return 400 and a JSON error array' do
      valid_params[:claim_id] = SecureRandom.uuid
      post_to_validate_endpoint
      expect_error_response('Claim cannot be blank')
    end

    it 'returns 400 and JSON error when dates are not in acceptable format' do
      valid_params[:date_of_birth] = '10-05-1980'
      post_to_validate_endpoint
      expect_error_response('date_of_birth is not in an acceptable date format (YYYY-MM-DD[T00:00:00])')
    end
  end
end

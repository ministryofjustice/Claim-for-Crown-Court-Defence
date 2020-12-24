require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::DateAttended do
  include Rack::Test::Methods
  include ApiSpecHelper

  ALL_DATES_ATTENDED_ENDPOINTS = [endpoint(:dates_attended, :validate), endpoint(:dates_attended)]
  FORBIDDEN_DATES_ATTENDED_VERBS = [:get, :put, :patch, :delete]

  let!(:provider) { create(:provider) }
  let!(:claim) { create(:claim, source: 'api') }
  let!(:fee) { create(:misc_fee, claim: claim) }
  let!(:from_date) { claim.earliest_representation_order_date }
  let!(:to_date) { from_date + 2.days }
  let!(:valid_params) { { api_key: provider.api_key, attended_item_id: fee.reload.uuid, date: from_date.as_json, date_to: to_date.as_json } }

  context 'when sending non-permitted verbs' do
    ALL_DATES_ATTENDED_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_DATES_ATTENDED_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe "POST #{endpoint(:dates_attended)}" do
    def post_to_create_endpoint
      post endpoint(:dates_attended), valid_params, format: :json
    end

    include_examples 'should NOT be able to amend a non-draft claim'

    context 'when date_attended params are valid' do
      it 'should create date_attended, return 201 and date_attended JSON output including UUID' do
        post_to_create_endpoint
        expect(last_response.status).to eq 201
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(DateAttended.find_by(uuid: json['id']).uuid).to eq(json['id'])
        expect(DateAttended.find_by(uuid: json['id']).attended_item.uuid).to eq(json['attended_item_id'])
      end

      it 'should create one new date attended' do
        expect { post_to_create_endpoint }.to change { DateAttended.count }.by(1)
      end

      it 'should be associated with fee' do
        post_to_create_endpoint
        expect(fee.reload.dates_attended.count).to eq(1)
      end

      it 'should create a new record using the params provided' do
        post_to_create_endpoint
        date_attended = DateAttended.last
        expect(date_attended.date).to eq valid_params[:date].to_date
        expect(date_attended.date_to).to eq valid_params[:date_to].to_date
        expect(date_attended.attended_item_id).to eq fee.id
      end
    end

    context 'when date_attended params are invalid' do
      include_examples 'invalid API key create endpoint', exclude: :other_provider

      context 'missing expected params' do
        it 'should return a JSON error array with required model attributes' do
          valid_params.delete(:date)
          post_to_create_endpoint
          expect_error_response('Enter the date attended (from)')
        end
      end

      context 'missing attended item id' do
        it 'should return 400 and a JSON error array' do
          valid_params.delete(:attended_item_id)
          post_to_create_endpoint
          expect_error_response('Attended item cannot be blank')
        end
      end

      context 'invalid attended item id' do
        it 'should return 400 and a JSON error array' do
          valid_params[:attended_item_id] = SecureRandom.uuid
          post_to_create_endpoint
          expect_error_response('Attended item cannot be blank')
        end
      end

      context 'malformed attended_item_id UUID' do
        it 'rejects malformed uuids' do
          valid_params[:attended_item_id] = 'any-old-rubbish'
          post_to_create_endpoint
          expect_error_response('Attended item cannot be blank')
        end
      end

      include_examples 'malformed or not iso8601 compliant dates', action: :create, attributes: [:date, :date_to]
    end
  end

  describe "POST #{endpoint(:dates_attended, :validate)}" do
    def post_to_validate_endpoint
      post endpoint(:dates_attended, :validate), valid_params, format: :json
    end

    include_examples 'invalid API key validate endpoint', exclude: :other_provider

    it 'valid requests should return 200 and String true' do
      post_to_validate_endpoint
      expect_validate_success_response
    end

    it 'missing required params should return 400 and a JSON error array' do
      valid_params.delete(:date)
      post_to_validate_endpoint
      expect_error_response('Enter the date attended (from)')
    end

    it 'invalid attended item id should return 400 and a JSON error array' do
      valid_params[:attended_item_id] = SecureRandom.uuid
      post_to_validate_endpoint
      expect_error_response('Attended item cannot be blank')
    end

    include_examples 'malformed or not iso8601 compliant dates', action: :validate, attributes: [:date, :date_to]
  end
end

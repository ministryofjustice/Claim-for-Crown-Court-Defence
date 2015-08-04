require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::DateAttended do

  include Rack::Test::Methods

  CREATE_DATE_ATTENDED_ENDPOINT = "/api/advocates/dates_attended"
  VALIDATE_DATE_ATTENDED_ENDPOINT = "/api/advocates/dates_attended/validate"

  let!(:fee)                            { create(:fee, id: 1) }
  let!(:valid_date_attended_params)     { {fee_id: fee.reload.uuid, date: '10 May 2015', date_to: '12 May 2015'} }
  let!(:invalid_date_attended_params)   { {} }

  describe 'POST api/advocates/dates_attended' do

    def post_to_create_endpoint(params)
      post CREATE_DATE_ATTENDED_ENDPOINT, params, format: :json
    end

    context 'when date_attended params are valid' do

      it 'returns status 201' do
        response = post_to_create_endpoint(valid_date_attended_params)
        expect(response.status).to eq 201
      end

      it 'creates a new record using the params provided' do
        response = post_to_create_endpoint(valid_date_attended_params)
        date_attended = DateAttended.last
        expect(date_attended.date).to eq '10 May 2015'
        expect(date_attended.date_to).to eq '12 May 2015'
        expect(date_attended.fee_id).to eq 1
      end

    end

    context 'when date_attended params are invalid' do

      it 'returns 400 and an appropriate error message in the response body' do
        invalid_response = post_to_create_endpoint(invalid_date_attended_params)
        expect(invalid_response.status).to eq 400
        expect(invalid_response.body).to eq "{\"error\":\"fee_id is missing, date is missing\"}"
      end

    end

  end

  describe "POST /api/advocates/dates_attended/validate" do

    def post_to_validate_endpoint(params)
      post VALIDATE_DATE_ATTENDED_ENDPOINT, params, format: :json
    end

    it 'returns 200 when the params are valid' do
      response = post_to_validate_endpoint(valid_date_attended_params)
      expect(response.status).to eq 200
    end

    it 'with MISSING PARAMS returns 400 and an appropriate error message' do
      invalid_response = post_to_validate_endpoint(invalid_date_attended_params)
      expect(invalid_response.status).to eq 400
      expect(invalid_response.body).to eq "{\"error\":\"fee_id is missing, date is missing\"}"
    end

  end

end


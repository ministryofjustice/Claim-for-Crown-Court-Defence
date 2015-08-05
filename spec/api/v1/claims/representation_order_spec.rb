require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::RepresentationOrder do

  include Rack::Test::Methods

  CREATE_REPRESENTATION_ORDER_ENDPOINT = "/api/advocates/representation_orders"
  VALIDATE_REPRESENTATION_ORDER_ENDPOINT = "/api/advocates/representation_orders/validate"

  ALL_REP_ORDER_ENDPOINTS = [VALIDATE_REPRESENTATION_ORDER_ENDPOINT, CREATE_REPRESENTATION_ORDER_ENDPOINT]
  FORBIDDEN_REP_ORDER_VERBS = [:get, :put, :patch, :delete]

  let!(:claim) { create(:claim) }
  let!(:defendant) { create(:defendant, claim: claim).reload }
  let!(:valid_params)    { {granting_body: "Magistrate's Court", defendant_id: defendant.uuid, representation_order_date: '10 June 2015', maat_reference: 'maatmaatmaat' } }
  let!(:invalid_params)  { {} }

  context 'All representation_order API endpoints' do
    ALL_REP_ORDER_ENDPOINTS.each do |endpoint| # for each endpoint
      context 'when sent a non-permitted verb' do
        FORBIDDEN_REP_ORDER_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it 'should return a status of 405' do
            response = send api_verb, endpoint, format: :json
            expect(response.status).to eq 405
          end
        end
      end
    end
  end

  describe 'POST api/advocates/representation_orders' do

    def post_to_create_endpoint(params)
      post CREATE_REPRESENTATION_ORDER_ENDPOINT, params, format: :json
    end

    context 'when representation_order params are valid' do

      it 'returns status of 201' do
        response = post_to_create_endpoint(valid_params)
        expect(response.status).to eq 201
      end

      it 'creates a new representation_order record with all provided attributes' do
        post_to_create_endpoint(valid_params)
        representation_order = RepresentationOrder.last
        expect(representation_order.granting_body).to eq "Magistrate's Court"
        expect(representation_order.defendant_id).to eq Defendant.find_by(uuid: defendant.uuid).id
        expect(representation_order.representation_order_date.to_s).to eq  "10/06/2015 00:00"
        expect(representation_order.maat_reference).to eq 'MAATMAATMAAT'
      end

      it 'returns JSON with UUIDs instead of IDs' do
        response = post_to_create_endpoint(valid_params)
        json_response = JSON.parse(response.body)

        expect(json_response['id']).not_to be_nil
        expect(RepresentationOrder.find_by(uuid: json_response['id']).uuid).to eq(json_response['id'])
        expect(RepresentationOrder.find_by(uuid: json_response['id']).defendant.uuid).to eq(json_response['defendant_id'])
      end

    end

    context 'when params are invalid' do

      it 'returns status of 400' do
        response = post_to_create_endpoint(invalid_params)
        expect(response.status).to eq 400
      end

      it 'the response body contains an appropriate error message' do
        response = post_to_create_endpoint(invalid_params)
        expect(response.body).to eq "{\"error\":\"defendant_id is missing, granting_body is missing, maat_reference is missing, representation_order_date is missing\"}"
      end

    end

  end

  describe 'POST api/advocates/representation_orders' do

    def post_to_validate_endpoint(params)
      post VALIDATE_REPRESENTATION_ORDER_ENDPOINT, params, format: :json
    end

    context 'when params are valid' do

      it 'returns status 200' do
        response = post_to_validate_endpoint(valid_params)
        expect(response.status).to eq 200
      end

    end

    context 'when params are invalid' do

      it 'returns status 400' do
        response = post_to_validate_endpoint(invalid_params)
        expect(response.status).to eq 400
      end

      it 'the response body contains and appropriate error message' do
        response = post_to_validate_endpoint(invalid_params)
        expect(response.body).to eq "{\"error\":\"defendant_id is missing, granting_body is missing, maat_reference is missing, representation_order_date is missing\"}"
      end

    end

  end

end

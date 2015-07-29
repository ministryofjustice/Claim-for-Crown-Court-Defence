require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::RepresentationOrder do

  include Rack::Test::Methods

  CREATE_REPRESENTATION_ORDER_ENDPOINT = "/api/advocates/representation_orders"
  VALIDATE_REPRESENTATION_ORDER_ENDPOINT = "/api/advocates/representation_orders/validate"

  let!(:valid_representation_order_params)    { {granting_body: "Magistrate's Court", defendant_id: 1, representation_order_date: '10 June 2015', maat_reference: 'maatmaatmaat' } }
  let!(:invalid_representation_order_params)  { {} }

  describe 'POST api/advocates/representation_orders' do

    def post_to_create_endpoint(params)
      post CREATE_REPRESENTATION_ORDER_ENDPOINT, params, format: :json
    end

    context 'when representation_order params are valid' do

      it 'returns status of 201' do
        response = post_to_create_endpoint(valid_representation_order_params)
        expect(response.status).to eq 201
      end

      it 'creates a new representation_order record with all provided attributes' do
        post_to_create_endpoint(valid_representation_order_params)
        representation_order = RepresentationOrder.last
        expect(representation_order.granting_body).to eq "Magistrate's Court"
        expect(representation_order.defendant_id).to eq 1
        expect(representation_order.representation_order_date.to_s).to eq  "10/06/2015 00:00"
        expect(representation_order.maat_reference).to eq 'MAATMAATMAAT'
      end

    end

    context 'when params are invalid' do

      it 'returns status of 400' do
        response = post_to_create_endpoint(invalid_representation_order_params)
        expect(response.status).to eq 400
      end

      it 'the response body contains an appropriate error message' do
        response = post_to_create_endpoint(invalid_representation_order_params)
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
        response = post_to_validate_endpoint(valid_representation_order_params)
        expect(response.status).to eq 200
      end

    end

    context 'when params are invalid' do

      it 'returns status 400' do
        response = post_to_validate_endpoint(invalid_representation_order_params)
        expect(response.status).to eq 400
      end

      it 'the response body contains and appropriate error message' do
        response = post_to_validate_endpoint(invalid_representation_order_params)
        expect(response.body).to eq "{\"error\":\"defendant_id is missing, granting_body is missing, maat_reference is missing, representation_order_date is missing\"}"
      end

    end

  end

end

require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::RepresentationOrder do

  include Rack::Test::Methods

  CREATE_REPRESENTATION_ORDER_ENDPOINT = "/api/advocates/representation_orders"
  VALIDATE_REPRESENTATION_ORDER_ENDPOINT = "/api/advocates/representation_orders/validate"

  ALL_REP_ORDER_ENDPOINTS = [VALIDATE_REPRESENTATION_ORDER_ENDPOINT, CREATE_REPRESENTATION_ORDER_ENDPOINT]
  FORBIDDEN_REP_ORDER_VERBS = [:get, :put, :patch, :delete]

  let!(:claim)            { create(:claim, source: 'api') }
  let!(:defendant)        { create(:defendant, claim: claim).reload }
  let!(:valid_params)     { {granting_body: "Magistrates' Court", defendant_id: defendant.uuid, representation_order_date: '2015-06-10', maat_reference: 'maatmaatmaat' } }

  context 'when sending non-permitted verbs' do
    ALL_REP_ORDER_ENDPOINTS.each do |endpoint| # for each endpoint
      context "to endpoint #{endpoint}" do
        FORBIDDEN_REP_ORDER_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
          it "#{api_verb.upcase} should return a status of 405" do
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

      it "should create fee, return 201 and expense JSON output including UUID" do
        response = post_to_create_endpoint(valid_params)
        expect(response.status).to eq 201
        json = JSON.parse(response.body)
        expect(json['id']).not_to be_nil
        expect(RepresentationOrder.find_by(uuid: json['id']).uuid).to eq(json['id'])
        expect(RepresentationOrder.find_by(uuid: json['id']).defendant.uuid).to eq(json['defendant_id'])
      end

      it "should create one new representation_order" do
        expect{ post_to_create_endpoint(valid_params) }.to change { RepresentationOrder.count }.by(1)
      end

      it 'creates a new representation_order record with all provided attributes' do
        post_to_create_endpoint(valid_params)
        new_representation_order = RepresentationOrder.last
        expect(new_representation_order.granting_body).to eq valid_params[:granting_body]
        expect(new_representation_order.defendant_id).to eq defendant.id
        expect(new_representation_order.representation_order_date).to eq valid_params[:representation_order_date].to_date
        expect(new_representation_order.maat_reference).to eq valid_params[:maat_reference].upcase!
      end

    end

    context 'when params are invalid' do

      context "missing expected params" do
        it "should return a JSON error array with required model attributes" do
          valid_params.delete(:granting_body)
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq "[{\"error\":\"Granting body can't be blank\"},{\"error\":\"Granting body is not included in the list\"}]"
        end
      end

      context "unexpected error" do
        it "should return 400 and JSON error array of error message" do
          valid_params[:maat_reference] = 'a'*256
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq(400)
          json = JSON.parse(response.body)
          expect(json[0]['error']).to include("PG::StringDataRightTruncation: ERROR:  value too long for type character varying(255)")
        end
      end

      context 'missing defendant id' do
        it 'should return 400 and a JSON error array' do
          valid_params.delete(:defendant_id)
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq "[{\"error\":\"Defendant can't be blank\"}]"
        end
      end

      context 'invalid defendant id' do
        it 'should return 400 and a JSON error array' do
          valid_params[:defendant_id] = SecureRandom.uuid
          response = post_to_create_endpoint(valid_params)
          expect(response.status).to eq 400
          expect(response.body).to eq "[{\"error\":\"Defendant can't be blank\"}]"
        end
      end

    end

  end

  describe 'POST api/advocates/representation_orders' do

    def post_to_validate_endpoint(params)
      post VALIDATE_REPRESENTATION_ORDER_ENDPOINT, params, format: :json
    end

   it 'valid requests should return 200 and String true' do
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json).to eq({ "valid" => true })
    end

    it 'missing required params should return 400 and a JSON error array' do
      valid_params.delete(:representation_order_date)
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq "[{\"error\":\"Representation order date can't be blank\"}]"
    end

    it 'invalid claim id should return 400 and a JSON error array' do
      valid_params[:defendant_id] = SecureRandom.uuid
      response = post_to_validate_endpoint(valid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq "[{\"error\":\"Defendant can't be blank\"}]"
    end

    it 'returns 400 and JSON error when dates are not in standard JSON format' do
      invalid_params = valid_params
      invalid_params[:representation_order_date] = '10-06-2015'
      response = post_to_validate_endpoint(invalid_params)
      expect(response.status).to eq 400
      expect(response.body).to eq "[{\"error\":\"representation_order_date is not in standard JSON date format (YYYY-MM-DD)\"}]"
    end

  end

end

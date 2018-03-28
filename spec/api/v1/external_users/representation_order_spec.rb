require 'rails_helper'
require 'api_spec_helper'
require_relative 'shared_examples_for_all'

describe API::V1::ExternalUsers::RepresentationOrder do

  include Rack::Test::Methods
  include ApiSpecHelper

  CREATE_REPRESENTATION_ORDER_ENDPOINT = "/api/external_users/representation_orders"
  VALIDATE_REPRESENTATION_ORDER_ENDPOINT = "/api/external_users/representation_orders/validate"

  ALL_REP_ORDER_ENDPOINTS = [VALIDATE_REPRESENTATION_ORDER_ENDPOINT, CREATE_REPRESENTATION_ORDER_ENDPOINT]
  FORBIDDEN_REP_ORDER_VERBS = [:get, :put, :patch, :delete]

  let(:representation_order_date) { Date.new(2017, 6, 1) }

  let!(:provider)      { create(:provider) }
  let!(:claim)         { create(:claim, create_defendant_and_rep_order: false, source: 'api', offence: create(:offence, :with_fee_scheme)) }
  let!(:defendant)     { create(:defendant, :without_reporder, claim: claim).reload }
  let!(:valid_params)  {
    {
        api_key: provider.api_key,
        defendant_id: defendant.uuid,
        representation_order_date: representation_order_date.as_json,
        maat_reference: '0123456789'
    }
  }

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

  describe "POST #{CREATE_REPRESENTATION_ORDER_ENDPOINT}" do

    def post_to_create_endpoint(submission_date = Date.new(2017, 7, 1))
      Timecop.freeze(submission_date) { post CREATE_REPRESENTATION_ORDER_ENDPOINT, valid_params, format: :json }
    end

    include_examples "should NOT be able to amend a non-draft claim"

    context 'when representation_order params are valid' do
      it "should create fee, return 201 and expense JSON output including UUID" do
        post_to_create_endpoint
        expect(last_response.status).to eq 201
        json = JSON.parse(last_response.body)
        expect(json['id']).not_to be_nil
        expect(RepresentationOrder.find_by(uuid: json['id']).uuid).to eq(json['id'])
        expect(RepresentationOrder.find_by(uuid: json['id']).defendant.uuid).to eq(json['defendant_id'])
      end

      it "should create one new representation_order" do
        expect{ post_to_create_endpoint }.to change { RepresentationOrder.count }.by(1)
      end

      context 'MAAT reference' do
        context 'when case type requires MAAT reference' do
          before { claim.case_type.update_column(:requires_maat_reference, true) }

          it 'creates a new representation_order record with all provided attributes' do
            post_to_create_endpoint
            new_representation_order = RepresentationOrder.last
            expect(new_representation_order.defendant_id).to eq defendant.id
            expect(new_representation_order.representation_order_date).to eq valid_params[:representation_order_date].to_date
            expect(new_representation_order.maat_reference).to eq valid_params[:maat_reference]
          end
        end

        context 'when case type does not require MAAT reference' do
          before { claim.case_type.update_column(:requires_maat_reference, false) }

          it 'creates a new representation_order record with all provided attributes' do
            post_to_create_endpoint
            new_representation_order = RepresentationOrder.last
            expect(new_representation_order.defendant_id).to eq defendant.id
            expect(new_representation_order.representation_order_date).to eq valid_params[:representation_order_date].to_date
            expect(new_representation_order.maat_reference).to eq nil
          end
        end
      end
    end

    context 'when params are invalid' do
      context 'invalid API key' do
        include_examples "invalid API key create endpoint"
      end

      context 'missing defendant id' do
        it 'should return 400 and a JSON error array' do
          valid_params.delete(:defendant_id)
          post_to_create_endpoint
          expect_error_response("Defendant cannot be blank")
        end
      end

      context 'invalid defendant id' do
        it 'should return 400 and a JSON error array' do
          valid_params[:defendant_id] = SecureRandom.uuid
          post_to_create_endpoint
          expect_error_response("Defendant cannot be blank")
        end
      end
    end

    context 'when a claim has been submitted with an AGFS scheme 10 offence' do
      let(:claim) { create(:claim, create_defendant_and_rep_order: false, source: 'api', offence: create(:offence, :with_fee_scheme_ten)) }
      let(:defendant) { create(:defendant, :without_reporder, claim: claim).reload }
      let(:representation_order_date) { Date.today }

      describe 'and the rep_order_date pre-dates the start of the scheme' do

        before { Timecop.freeze(2018, 1, 1) { post_to_create_endpoint } }

        specify { expect_error_response("Representation Order Date is not valid for AGFS scheme ten") }
      end

      describe 'and the rep_order_date post-dates the start of the scheme' do
        specify { expect{ post_to_create_endpoint(Date.new(2018, 5, 1)) }.to change { RepresentationOrder.count }.by(1) }
      end
    end
  end

  describe "POST #{VALIDATE_REPRESENTATION_ORDER_ENDPOINT}" do

    def post_to_validate_endpoint
      post VALIDATE_REPRESENTATION_ORDER_ENDPOINT, valid_params, format: :json
    end

   it 'valid requests should return 200 and String true' do
      post_to_validate_endpoint
      expect_validate_success_response
    end

    context 'invalid API key' do
      include_examples "invalid API key validate endpoint"
    end

    it 'missing required params should return 400 and a JSON error array' do
      valid_params.delete(:representation_order_date)
      post_to_validate_endpoint
      expect_error_response("Enter a representation order date for the representation order of the defendant")
    end

    it 'invalid claim id should return 400 and a JSON error array' do
      valid_params[:defendant_id] = SecureRandom.uuid
      post_to_validate_endpoint
      expect_error_response("Defendant cannot be blank")
    end

    it 'returns 400 and JSON error when dates are not in acceptable format' do
      valid_params[:representation_order_date] = '10-06-2015'
      post_to_validate_endpoint
      expect_error_response("representation_order_date is not in an acceptable date format (YYYY-MM-DD[T00:00:00])")
    end

  end

end

require 'rails_helper'
require 'spec_helper'
require 'api_spec_helper'

describe API::V2::CaseWorkers::Allocate do
  include Rack::Test::Methods
  include ApiSpecHelper

  ALLOCATION_ENDPOINT = '/api/case_workers/allocate'
  FORBIDDEN_ALLOCATION_VERBS = [:get, :put, :patch, :delete]

  let(:case_worker) { create :user, email: 'caseworker@example.com' }
  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:external_user) { create(:external_user) }
  let(:valid_base_params) { { api_key: api_key, case_worker_id: case_worker.id } }
  let(:valid_array_params) { valid_base_params.merge( claim_ids: '1, 2, 3' ) }
  let(:invalid_array_params) { valid_base_params.merge( claim_ids: %w(1 2 3) ) }
  let(:api_key) { case_worker_admin.user.api_key }

  before { case_worker_admin.user = case_worker }

  def do_request
    post ALLOCATION_ENDPOINT, params, format: :json
  end

  def configure_params(params)
    params.except(:api_key).merge(allocating: true, current_user: case_worker).to_h.stringify_keys
  end

  context 'when sending non-permitted verbs' do
    context 'to the allocation endpoint' do
      FORBIDDEN_ALLOCATION_VERBS.each do |api_verb| # test that each FORBIDDEN_VERB returns 405
        it "#{api_verb.upcase} should return a status of 405" do
          response = send api_verb, ALLOCATION_ENDPOINT, format: :json
          expect(response.status).to eq 405
        end
      end
    end
  end

  describe 'POST allocate' do
    let(:allocation) { double Allocation }

    context 'new test' do
      let(:params) { valid_array_params }

      before do
        expect(Allocation).to receive(:new).and_return(allocation)
        expect(allocation).to receive(:save).and_return(true)
        expect(allocation).to receive(:successful_claims).and_return(build_list(:allocated_claim, 3).to_a)
        do_request
      end

      it 'should succeed' do
        expect(last_response.status).to eq 201
      end
    end

    context 'with valid array params' do
      let(:params) { valid_array_params }

      context 'when accessed by a CaseWorker' do
        let(:claims) { create_list(:allocated_claim, 3) }
        before do
          allow(Allocation).to receive(:new).and_return(allocation)
          allow(allocation).to receive(:save).and_return(true)
          allow(allocation).to receive(:successful_claims).and_return(claims.to_a)
          do_request
        end

        it 'should succeed' do
          expect(last_response.status).to eq 201
        end

        it 'should return a JSON with the required information' do
          body = JSON.parse(last_response.body, symbolize_names: true)
          claim_ids = claims.map(&:id).to_a
          expected = { result: true, allocated_claims: claim_ids } # TODO: Update this, what should be returned

          expect(body).to eq(expected)
        end
      end

      context 'when accessed by a ExternalUser' do
        let(:api_key) { external_user.user.api_key }
        before { do_request }

        it 'returns unauthorised' do
          expect(last_response.status).to eq 401
          expect(last_response.body).to include('Unauthorised')
        end
      end
    end

    context 'when a valid user passes invalid parameters' do
      let(:params) { invalid_array_params }
      before { do_request }

      it 'should return JSON containing an error description' do
        body = JSON.parse(last_response.body, symbolize_names: true)
        expected = [{:error=>'claim_ids is invalid'}]

        expect(body).to eq(expected)
      end
    end
  end
end

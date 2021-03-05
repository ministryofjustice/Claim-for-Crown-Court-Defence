require 'rails_helper'

RSpec.describe API::V2::CaseWorkers::Allocate do
  include Rack::Test::Methods
  include ApiSpecHelper

  ALLOCATION_ENDPOINT = '/api/case_workers/allocate'
  FORBIDDEN_ALLOCATION_VERBS = [:get, :put, :patch, :delete]

  let(:case_worker_user) { create :user, email: 'caseworker@example.com' }
  let(:case_worker) { create(:case_worker, :admin, user: case_worker_user) }
  let(:external_user) { create(:external_user) }
  let(:valid_base_params) { { api_key: api_key, case_worker_id: case_worker.id } }
  let(:api_key) { case_worker.user.api_key }

  before { case_worker.user = case_worker_user }

  def do_request
    post ALLOCATION_ENDPOINT, params, format: :json
  end

  def configure_params(params)
    params.except(:api_key).merge(allocating: true, current_user: case_worker.user).to_h.stringify_keys
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
    before { do_request }

    let(:claims) { create_list(:submitted_claim, 3) }
    let(:claim_ids) { claims.map(&:id).join(', ') }
    let(:params) { valid_base_params.merge(claim_ids: claim_ids) }

    context 'with claim_ids as comma-separated string' do
      it 'returns http status 201' do
        expect(last_response.status).to eq 201
      end

      it 'returns a JSON with the required information' do
        body = JSON.parse(last_response.body, symbolize_names: true)
        expected = { result: true, allocated_claims: claims.map(&:id), errors: [] }
        expect(body).to eq(expected)
      end
    end

    context 'with claim_ids as array of strings' do
      let(:claim_ids) { claims.map { |c| c.id.to_s } }

      it 'returns JSON containing an error description' do
        body = JSON.parse(last_response.body, symbolize_names: true)
        expected = [{ :error => 'claim_ids is invalid' }]
        expect(body).to eq(expected)
      end
    end

    context 'when accessed by a ExternalUser' do
      let(:api_key) { external_user.user.api_key }

      it 'returns unauthorised' do
        expect(last_response.status).to eq 401
        expect(last_response.body).to include('Unauthorised')
      end
    end

    context 'when allocating cases where one is already allocated' do
      let(:claims) do
        claims = create_list(:submitted_claim, 1)
        claims << create(:allocated_claim)
      end

      it 'returns a JSON with error messages' do
        body = JSON.parse(last_response.body, symbolize_names: true)
        expect(body[:errors][0]).to match(/Claim .* has already been allocated/)
      end
    end

    context 'caching' do
      it 'does not cache response' do
        expect(last_response.headers['Cache-Control'][/max-age=([0-9]+)/, 1]).to eq '0'
      end
    end
  end
end

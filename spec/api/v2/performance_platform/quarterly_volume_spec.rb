require 'rails_helper'

RSpec.describe API::V2::PerformancePlatform::QuarterlyVolume do
  include Rack::Test::Methods
  include ApiSpecHelper
  include DatabaseHousekeeping
  include ActiveSupport::Testing::TimeHelpers

  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:external_user) { create(:external_user) }
  let(:start_date) { Date.new(2018, 1, 1) }
  let(:get_params) { { api_key: api_key, start_date: start_date, value_1: value_1, value_2: value_2, value_3: value_3 } }
  let(:value_1) { 1000 }
  let(:value_2) { 2000 }
  let(:value_3) { 3000 }

  def do_get_request
    get '/api/performance_platform/quarterly_volume', get_params
  end

  describe 'GET quarterly_volume' do
    before { do_get_request }

    context 'when accessed by a CaseWorker' do
      context 'when report not previously generated' do
        let(:api_key) { case_worker_admin.user.api_key }

        it 'returns success' do
          expect(last_response).to be_ok
        end
      end
    end


    context 'when accessed by an user that has no permissions' do
      let(:api_key) { external_user.user.api_key }

      it 'returns unauthorised' do
        expect(last_response).to be_unauthorized
        expect(last_response.body).to include('Unauthorised')
      end
    end
  end

  describe 'POST quarterly_volume' do
    let(:post_params) { { api_key: api_key, start_date: start_date } }

    def do_request
      post '/api/performance_platform/quarterly_volume', post_params
    end

    before { do_request }

    context 'when report not previously generated' do
      let(:api_key) { case_worker_admin.user.api_key }

      it 'returns a 404 error' do
        expect(last_response.status).to eq 400
      end

      it 'returns the correct error' do
        expect(last_response.body).to include('No report exists')
      end
    end

    context 'when report exists' do
      let(:api_key) { case_worker_admin.user.api_key }

      before { do_get_request }

      it 'returns success' do
        expect(last_response).to be_ok
      end
    end

    context 'when accessed by an user that has no permissions' do
      let(:api_key) { external_user.user.api_key }

      it 'returns unauthorised' do
        expect(last_response).to be_unauthorized
        expect(last_response.body).to include('Unauthorised')
      end
    end
  end
end

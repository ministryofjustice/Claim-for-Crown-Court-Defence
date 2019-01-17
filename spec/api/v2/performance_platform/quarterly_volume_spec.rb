require 'rails_helper'

RSpec.describe API::V2::PerformancePlatform::QuarterlyVolume do
  include Rack::Test::Methods
  include ApiSpecHelper
  include DatabaseHousekeeping
  include ActiveSupport::Testing::TimeHelpers

  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:external_user) { create(:external_user) }
  let(:start_date) { Date.new(2018, 1, 1) }
  let(:get_params) { post_params.merge(value_1: value_1, value_2: value_2, value_3: value_3) }
  let(:post_params) { { api_key: api_key, start_date: start_date } }
  let(:value_1) { 1000 }
  let(:value_2) { 2000 }
  let(:value_3) { 3000 }

  def do_post_request
    post '/api/performance_platform/quarterly_volume', post_params
  end

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
    context 'when report not previously generated' do
      before { do_post_request }

      let(:api_key) { case_worker_admin.user.api_key }

      it 'returns a 400 error' do
        expect(last_response.status).to eq 400
      end

      it 'returns the correct error' do
        expect(last_response.body).to include('No report exists')
      end
    end

    context 'when report exists' do
      let(:api_key) { case_worker_admin.user.api_key }

      before do
        stub_request(:post, %r{\Ahttps://www.performance.service.gov.uk/data/.*\z}).to_return(status: 200, body: '{"status": "ok"}', headers: {})
        do_get_request
        do_post_request
      end

      it 'returns success' do
        expect(last_response.status).to eq 201
      end
    end

    context 'when accessed by an user that has no permissions' do
      let(:api_key) { external_user.user.api_key }

      before { do_post_request }

      it 'returns unauthorised' do
        expect(last_response).to be_unauthorized
        expect(last_response.body).to include('Unauthorised')
      end
    end
  end
end

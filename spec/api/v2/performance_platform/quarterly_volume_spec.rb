require 'rails_helper'

RSpec.describe API::V2::PerformancePlatform::QuarterlyVolume do
  include Rack::Test::Methods
  include ApiSpecHelper
  include DatabaseHousekeeping
  include ActiveSupport::Testing::TimeHelpers

  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:external_user) { create(:external_user) }
  let(:params) { default_params }
  let(:default_params) { { api_key: api_key, start_date: start_date, value_1: value_1, value_2: value_2, value_3: value_3 } }
  let(:start_date) { Date.new(2018, 1, 1) }
  let(:value_1) { 1000 }
  let(:value_2) { 2000 }
  let(:value_3) { 3000 }

  def do_request
    get '/api/performance_platform/quarterly_volume', params
  end

  describe 'GET quarterly_volume' do

    before { do_request }

    context 'when accessed by a CaseWorker' do
      let(:api_key) { case_worker_admin.user.api_key }

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

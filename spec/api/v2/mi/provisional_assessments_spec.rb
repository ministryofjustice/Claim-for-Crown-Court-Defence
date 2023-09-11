require 'rails_helper'

RSpec.describe API::V2::MI::ProvisionalAssessments do
  include Rack::Test::Methods
  include ApiSpecHelper
  include DatabaseHousekeeping
  include ActiveSupport::Testing::TimeHelpers

  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:external_user) { create(:external_user) }
  let(:default_params) { { api_key:, start_date:, end_date: } }
  let(:missing_params) { { api_key: } }
  let(:params) { default_params }
  let(:start_date) { Date.new(2018, 01, 01).to_s(:db) }
  let(:end_date) { Date.new(2018, 01, 31).to_s(:db) }
  let(:create_data?) { false }

  describe 'GET provisional_assessments', :slack_bot do
    def populate_mi_data
      travel_to(Date.new(2018, 01, 15)) { create_list(:archived_pending_delete_claim, 3) }
      travel_to(Date.new(2018, 02, 14)) { create_list(:archived_pending_delete_claim, 3) }
      TimedTransitions::BatchTransitioner.new(limit: 10, dummy: false).run
    end

    def do_request
      populate_mi_data if create_data?
      get '/api/mi/provisional_assessments', params, format: :json
    end

    context 'when accessed by a CaseWorker' do
      let(:api_key) { case_worker_admin.user.api_key }

      before do
        do_request
      end

      context 'and there is no data available' do
        context 'and dates are not provided' do
          let(:params) { missing_params }

          it 'returns an error' do
            expect(last_response.status).to eq 400
          end

          it 'returns a specific error message' do
            expect(last_response.body).to include('Please provide both dates in the format')
          end
        end

        context 'and no output format is provided' do
          let(:params) { default_params }

          it 'returns success' do
            expect(last_response).to be_ok
          end

          it 'returns JSON' do
            expect(last_response.headers['content-type']).to eq 'application/json'
          end

          it 'returns an empty response' do
            expect(JSON.parse(last_response.body)).to be_empty
          end
        end

        context 'and JSON is requested as the output format' do
          let(:params) { default_params.merge(format: 'json') }

          it 'returns success' do
            expect(last_response).to be_ok
          end

          it 'returns JSON' do
            expect(last_response.headers['content-type']).to eq 'application/json'
          end

          it 'returns an empty response' do
            expect(JSON.parse(last_response.body)).to be_empty
          end
        end

        context 'and CSV is requested as the output format' do
          let(:params) { default_params.merge(format: 'csv') }

          it 'returns success' do
            expect(last_response).to be_ok
          end

          it 'returns JSON' do
            expect(last_response.headers['content-type']).to eq 'text/csv; utf-8'
          end

          it 'returns a file with just the headers' do
            csv_content = CSV.parse(last_response.body)
            expect(csv_content.count).to eq 1
            expect(csv_content[0]).to match_array(Reports::ProvisionalAssessmentsByDates::COLUMNS)
          end
        end
      end

      context 'when data is available' do
        let(:create_data?) { true }

        it 'returns success' do
          expect(last_response).to be_ok
        end

        it 'returns JSON' do
          expect(last_response.headers['content-type']).to eq 'application/json'
        end

        it 'retrieves injection errors data from the provided date' do
          expect(JSON.parse(last_response.body).count).to eq(3)
        end

        context 'and with CSV output format' do
          let(:params) { default_params.merge(format: 'csv') }

          it 'returns success' do
            expect(last_response).to be_ok
          end

          it 'returns JSON' do
            expect(last_response.headers['content-type']).to eq 'text/csv; utf-8'
          end

          it 'returns a file with the headers and the data retrieved' do
            csv_content = CSV.parse(last_response.body)
            expect(csv_content.count).to eq(4)
            expect(csv_content[0]).to match_array(Reports::ProvisionalAssessmentsByDates::COLUMNS)
          end
        end
      end
    end

    context 'when accessed by an user that has no permissions' do
      let(:api_key) { external_user.user.api_key }

      it 'returns unauthorised' do
        do_request
        expect(last_response).to be_unauthorized
        expect(last_response.body).to include('Unauthorised')
      end
    end
  end
end

require 'rails_helper'
require 'api_spec_helper'

RSpec.describe API::V2::MI::AGFSSchemeTenClaims do
  include Rack::Test::Methods
  include ApiSpecHelper
  include DatabaseHousekeeping
  include ActiveSupport::Testing::TimeHelpers

  let(:case_worker_admin) { create(:case_worker, :admin) }
  let(:external_user) { create(:external_user) }
  let(:params) { { api_key: api_key } }
  let(:transitory_params) { {} }
  let(:expected_json_keys) { %i[id type defendant case_number claim_submitted case_type court offence offence_band provider_name user_name created_at representation_order_date] }

  let!(:not_included_claim1) { travel_to(DateTime.parse('31-MAR-2018 12:00')) { create :submitted_claim } }
  let!(:not_included_claim2) { travel_to(DateTime.parse('1-APR-2018 11:30')) { create :submitted_claim } }
  let!(:included_claim1) { travel_to(DateTime.parse('1-APR-2018 11:00')) { create :submitted_claim, :agfs_scheme_10 } }
  let!(:included_claim2) { travel_to(DateTime.parse('5-APR-2018 10:30')) { create :submitted_claim, :agfs_scheme_10 } }

  def do_request
    get '/api/mi/scheme_10_claims', params.merge!(transitory_params), format: :json
  end

  RSpec.shared_examples 'MI JSON return' do
    it 'returns success' do
      expect(last_response).to be_ok
    end

    it 'returns JSON' do
      expect(last_response.headers['content-type']).to eq 'application/json'
    end

    it 'returns JSON keys' do
      result_keys = JSON.parse(last_response.body, symbolize_names: true).first.all_keys
      expect(result_keys).to eq(expected_json_keys)
    end

    it 'returns the expected two rows' do
      expect(JSON.parse(last_response.body).count).to eq 2
    end
  end

  describe 'GET s10_claims' do
    before { travel_to Date.parse('21-APR-2018') }
    after { travel_back }

    context 'when accessed by a CaseWorker' do
      let(:api_key) { case_worker_admin.user.api_key }

      before { do_request }

      context 'with no format' do
        it_behaves_like 'MI JSON return'
      end

      context 'with JSON format' do
        let(:transitory_params) { { format: 'json' } }

        it_behaves_like 'MI JSON return'

        context 'when passed a date with no data' do
          let(:transitory_params) { { format: 'json', date: '2018-04-04' } }

          it 'returns an empty array' do
            expect(JSON.parse(last_response.body).count).to eq 0
          end
        end
      end

      context 'with csv format' do
        let(:transitory_params) { { format: 'csv' } }

        it 'returns success' do
          expect(last_response).to be_ok
        end

        it 'returns CSV' do
          expect(last_response.headers['content-type']).to eq 'text/csv; utf-8'
        end

        it 'returns 2 rows of data and a header row' do
          expect(CSV.parse(last_response.body).count).to eq 3
        end

        context 'when passed a date with no data' do
          let(:transitory_params) { { format: 'csv', date: '2018-04-04' } }

          it 'returns an empty array' do
            expect(CSV.parse(last_response.body)).to eq [['No scheme ten claims filed on'], ['2018-04-04']]
          end
        end

      end
    end

    context 'when accessed by a ExternalUser' do
      before { do_request }
      let(:api_key) { external_user.user.api_key }

      it 'returns unauthorised' do
        expect(last_response).to be_unauthorized
        expect(last_response.body).to include('Unauthorised')
      end
    end
  end
end
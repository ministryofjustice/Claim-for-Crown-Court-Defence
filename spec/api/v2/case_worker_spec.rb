require 'rails_helper'

describe API::V2::CaseWorker do
  include Rack::Test::Methods

  after(:all) { clean_database }

  let(:get_case_workers_endpoint) { '/api/case_workers' }
  let(:case_workers) { create_list(:case_worker, 3) }
  let(:external_user) { create(:external_user) }
  let(:sorting) { {} }
  let(:params) do
    {
      api_key:
    }.merge(sorting)
  end
  let(:api_key) { case_workers.first.user.api_key }

  def do_request
    get get_case_workers_endpoint, params, format: :json
  end

  describe 'GET case workers' do
    it 'returns 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v1'

      do_request
      expect(last_response.status).to eq 406
      expect(last_response.body).to include('The requested version is not supported.')
    end

    it 'requires an API key' do
      params.delete(:api_key)

      do_request
      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Unauthorised')
    end

    context 'when accessed by a ExternalUser' do
      let(:api_key) { external_user.user.api_key }

      it 'returns unauthorised' do
        do_request
        expect(last_response.status).to eq 401
        expect(last_response.body).to include('Unauthorised')
      end
    end

    it 'returns a JSON with the required information' do
      response = do_request
      expect(response.status).to eq 200

      body = JSON.parse(response.body, symbolize_names: true)
      cw = body.first

      expect(cw.keys.sort).to eq(%i[email first_name id last_name uuid])
    end

    context 'sorting' do
      let(:case_workers_ids) do
        response = do_request
        JSON.parse(response.body, symbolize_names: true).pluck(:id)
      end

      context 'default' do
        it 'sorts by ID ASC by default' do
          expect(case_workers_ids).to eq(case_workers.map(&:id).sort)
        end
      end

      context 'custom sorting' do
        let(:sorting) { { sorting: 'id', direction: 'desc' } }

        it 'sorts with specified params' do
          expect(case_workers_ids).to eq(case_workers.map(&:id).sort.reverse)
        end
      end
    end
  end
end

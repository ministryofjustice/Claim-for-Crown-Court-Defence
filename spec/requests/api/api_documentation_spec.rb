RSpec.describe 'API Swagger documentation' do
  describe 'GET /api/documentation' do
    before { get grape_swagger_rails_path }

    it { expect(response).to have_http_status :ok }
    it { expect(response.body).to include('Claim for crown court defence API') }
  end

  describe 'GET /api/v1/swagger_doc' do
    before { get '/api/v1/swagger_doc' }

    it { expect(response).to have_http_status :ok }
  end

  describe 'GET /api/v2/swagger_doc' do
    before { get '/api/v2/swagger_doc' }

    it { expect(response).to have_http_status :ok }
  end
end

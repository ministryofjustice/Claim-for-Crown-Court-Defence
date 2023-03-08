RSpec.describe 'API Swagger documentation' do
  describe 'GET /api/documentation' do
    before { get grape_swagger_rails_path }

    it { expect(response).to have_http_status :ok }
    it { expect(response.body).to include('Claim for crown court defence API') }
  end
end

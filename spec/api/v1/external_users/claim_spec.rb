require 'rails_helper'

RSpec.shared_examples 'API claim endpoint' do |endpoint|
  include Rack::Test::Methods

  it { expect(api_routes).to include(endpoint) }

  context 'when Accept-Version is set to v2' do
    before do
      header 'Accept-Version', 'v2'
      post endpoint, session: { format: :json }
    end

    it { expect(last_response).to have_http_status :not_acceptable }
    it { expect(last_response.body).to include('The requested version is not supported.') }
  end
end

RSpec.describe API::V1::ExternalUsers::Claim do
  let(:api_routes) do
    API::V1::Root.routes.each_with_object([]) do |route, api_routes|
      path = route.pattern.path
      api_routes << path.sub('(.:format)', '')
    end
  end

  it_behaves_like 'API claim endpoint', '/api/external_users/claims/advocates/final'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/advocates/final/validate'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/advocates/interim'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/advocates/interim/validate'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/advocates/supplementary'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/advocates/supplementary/validate'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/advocates/hardship'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/advocates/hardship/validate'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/final'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/final/validate'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/interim'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/interim/validate'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/transfer'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/transfer/validate'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/litigators/hardship'
  it_behaves_like 'API claim endpoint', '/api/external_users/claims/litigators/hardship/validate'
end

require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claim do
  include Rack::Test::Methods

  CLAIM_ENDPOINTS = %w(
    /api/external_users/claims
    /api/external_users/claims/validate

    /api/external_users/claims/advocates/final
    /api/external_users/claims/advocates/final/validate

    /api/external_users/claims/advocates/interim
    /api/external_users/claims/advocates/interim/validate

    /api/external_users/claims/advocates/supplementary
    /api/external_users/claims/advocates/supplementary/validate

    /api/external_users/claims/advocates/hardship
    /api/external_users/claims/advocates/hardship/validate

    /api/external_users/claims/final
    /api/external_users/claims/final/validate

    /api/external_users/claims/interim
    /api/external_users/claims/interim/validate

    /api/external_users/claims/transfer
    /api/external_users/claims/transfer/validate
  ).freeze

  let(:api_routes) do
    API::V1::Root.routes.each_with_object([]) do |route, api_routes|
      path = route.pattern.path
      api_routes << path.sub('(.:format)', '')
    end
  end

  describe 'Claim endpoints' do
    CLAIM_ENDPOINTS.each do |endpoint|
      it "should expose #{endpoint}" do
        expect(api_routes).to include(endpoint)
      end
    end
  end

  describe 'Support versioning via header' do
    it 'should return 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v2'

      CLAIM_ENDPOINTS.each do |endpoint|
        post endpoint, {}, format: :json
        expect(last_response.status).to eq 406
        expect(last_response.body).to include('The requested version is not supported.')
      end
    end
  end
end

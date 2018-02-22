require 'rails_helper'

describe API::V2::Root do
  include Rack::Test::Methods

  V2_ENDPOINTS = %w(
    /api/case_workers/claims
  ).freeze

  describe 'Endpoints' do
    before(:all) do
      @declared_routes = []
      API::V2::Root.routes.each do |route|
        path = route.pattern.path
        @declared_routes << path.sub('(.:format)', '')
      end
    end

    V2_ENDPOINTS.each do |endpoint|
      it "should expose #{endpoint}" do
        expect(@declared_routes).to include(endpoint)
      end
    end
  end

  describe 'Support versioning via header' do
    it 'should return 406 Not Acceptable if requested API version via header is not supported' do
      header 'Accept-Version', 'v1'

      V2_ENDPOINTS.each do |endpoint|
        post endpoint, {}, format: :json
        expect(last_response.status).to eq 406
        expect(last_response.body).to include('The requested version is not supported.')
      end
    end
  end
end

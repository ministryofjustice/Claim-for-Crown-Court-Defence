require 'rails_helper'
require 'spec_helper'

describe API::V1::ExternalUsers::Claim do

  CLAIM_ENDPOINTS = %w(
    /api/external_users/claims
    /api/external_users/claims/validate

    /api/external_users/claims/final
    /api/external_users/claims/final/validate

    /api/external_users/claims/interim
    /api/external_users/claims/interim/validate

    /api/external_users/claims/transfer
    /api/external_users/claims/transfer/validate
  ).freeze

  describe 'Claim endpoints' do
    before(:all) do
      @declared_routes = []
      API::V1::ExternalUsers::Root.routes.each do |route|
        info = route.instance_variable_get(:@options)
        @declared_routes << info[:path].sub('(.:format)', '')
      end
    end

    CLAIM_ENDPOINTS.each do |endpoint|
      it "should expose #{endpoint}" do
        expect(@declared_routes).to include(endpoint)
      end
    end
  end
end

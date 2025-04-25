require 'rails_helper'

ADVOCATE_SUPP_CLAIM_ENDPOINT = 'advocates/supplementary'.freeze
ADVOCATE_SUPP_VALIDATE_ENDPOINT = ClaimApiEndpoints.for(ADVOCATE_SUPP_CLAIM_ENDPOINT).validate

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::SupplementaryClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  let(:claim_class) { Claim::AdvocateSupplementaryClaim }
  let!(:provider)   { create(:provider) }
  let!(:vendor)     { create(:external_user, :admin, provider:) }
  let!(:advocate)   { create(:external_user, :advocate, provider:) }
  let!(:court)      { create(:court) }
  let(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_number: 'T20191234',
      advocate_category: 'Leading junior',
      court_id: court.id,
      main_hearing_date: Time.zone.today.as_json
    }
  end

  after(:all) { clean_database }

  include_examples 'malformed or not iso8601 compliant dates', action: :validate,
                                                               attributes: %i[main_hearing_date],
                                                               relative_endpoint: ADVOCATE_SUPP_VALIDATE_ENDPOINT
  include_examples 'optional parameter validation', optional_parameters: %i[main_hearing_date],
                                                    relative_endpoint: ADVOCATE_SUPP_VALIDATE_ENDPOINT
  it_behaves_like 'a claim endpoint', relative_endpoint: ADVOCATE_SUPP_CLAIM_ENDPOINT
  it_behaves_like 'a claim validate endpoint', relative_endpoint: ADVOCATE_SUPP_CLAIM_ENDPOINT
  it_behaves_like 'a claim create endpoint', relative_endpoint: ADVOCATE_SUPP_CLAIM_ENDPOINT
end

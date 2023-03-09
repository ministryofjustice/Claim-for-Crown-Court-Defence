require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::SupplementaryClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  SUPPLEMENTARY_CLAIM_ENDPOINT = 'advocates/supplementary'.freeze

  subject(:post_to_validate_endpoint) do
    post ClaimApiEndpoints.for(SUPPLEMENTARY_CLAIM_ENDPOINT).validate, valid_params, format: :json
  end

  let(:claim_class) { Claim::AdvocateSupplementaryClaim }
  let!(:provider) { create(:provider) }
  let!(:vendor) { create(:external_user, :admin, provider:) }
  let!(:advocate) { create(:external_user, :advocate, provider:) }
  let!(:court) { create(:court) }
  let(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_number: 'T20191234',
      advocate_category: 'Leading junior',
      court_id: court.id,
      main_hearing_date: Time.zone.today.strftime
    }
  end

  after { clean_database }

  include_examples 'advocate claim test setup'
  include_examples 'malformed or not iso8601 compliant dates', action: :validate, attributes: %i[main_hearing_date]
  include_examples 'optional parameter validation', optional_parameters: %i[main_hearing_date]
  it_behaves_like 'a claim endpoint', relative_endpoint: SUPPLEMENTARY_CLAIM_ENDPOINT
  it_behaves_like 'a claim validate endpoint', relative_endpoint: SUPPLEMENTARY_CLAIM_ENDPOINT
  it_behaves_like 'a claim create endpoint', relative_endpoint: SUPPLEMENTARY_CLAIM_ENDPOINT
end

require 'rails_helper'

ADVOCATE_INTERIM_CLAIM_ENDPOINT = 'advocates/interim'.freeze
ADVOCATE_INTERIM_VALIDATE_ENDPOINT = ClaimApiEndpoints.for(ADVOCATE_INTERIM_CLAIM_ENDPOINT).validate

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::InterimClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  let(:claim_class) { Claim::AdvocateInterimClaim }
  let!(:provider)   { create(:provider) }
  let!(:vendor)     { create(:external_user, :admin, provider:) }
  let!(:advocate)   { create(:external_user, :advocate, provider:) }
  let!(:offence)    { create(:offence, :with_fee_scheme_ten) }
  let!(:court)      { create(:court) }
  let(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_number: 'A20161234',
      advocate_category: 'Leading junior',
      offence_id: offence.id,
      court_id: court.id,
      main_hearing_date: Time.zone.today.as_json
    }
  end

  after(:all) { clean_database }

  include_examples 'malformed or not iso8601 compliant dates', action: :validate, attributes: %i[main_hearing_date],
                                                               relative_endpoint: ADVOCATE_INTERIM_VALIDATE_ENDPOINT
  include_examples 'optional parameter validation', optional_parameters: %i[main_hearing_date],
                                                    relative_endpoint: ADVOCATE_INTERIM_VALIDATE_ENDPOINT
  it_behaves_like 'a claim endpoint', relative_endpoint: ADVOCATE_INTERIM_CLAIM_ENDPOINT
  it_behaves_like 'a claim validate endpoint', relative_endpoint: ADVOCATE_INTERIM_CLAIM_ENDPOINT
  it_behaves_like 'a claim create endpoint', relative_endpoint: ADVOCATE_INTERIM_CLAIM_ENDPOINT
end

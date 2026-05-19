require 'rails_helper'

ADVOCATE_HARDSHIP_CLAIM_ENDPOINT = 'advocates/hardship'.freeze
ADVOCATE_HARDSHIP_VALIDATE_ENDPOINT = ClaimApiEndpoints.for(ADVOCATE_HARDSHIP_CLAIM_ENDPOINT).validate

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::HardshipClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  let(:claim_class)      { Claim::AdvocateHardshipClaim }
  let!(:provider)        { create(:provider) }
  let!(:vendor)          { create(:external_user, :admin, provider:) }
  let!(:advocate)        { create(:external_user, :advocate, provider:) }
  let!(:offence)         { create(:offence) }
  let!(:court)           { create(:court) }
  let(:trial_start_date) { 1.year.ago }
  let(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_stage_unique_code: create(:case_stage, :trial_not_concluded).unique_code,
      case_number: 'A20201234',
      first_day_of_trial: trial_start_date.as_json,
      trial_concluded_at: (trial_start_date + 9.days).as_json,
      estimated_trial_length: 10,
      actual_trial_length: 9,
      advocate_category: 'Led junior',
      offence_id: offence.id,
      court_id: court.id,
      main_hearing_date: trial_start_date.as_json
    }
  end

  after(:all) { clean_database }

  include_examples 'malformed or not iso8601 compliant dates',
                   action: :validate,
                   attributes: %i[first_day_of_trial trial_concluded_at main_hearing_date],
                   relative_endpoint: ADVOCATE_HARDSHIP_VALIDATE_ENDPOINT
  include_examples 'optional parameter validation',
                   optional_parameters: %i[trial_concluded_at
                                           estimated_trial_length
                                           actual_trial_length
                                           main_hearing_date],
                   relative_endpoint: ADVOCATE_HARDSHIP_VALIDATE_ENDPOINT
  it_behaves_like 'a claim endpoint', relative_endpoint: ADVOCATE_HARDSHIP_CLAIM_ENDPOINT
  it_behaves_like 'a claim validate endpoint', relative_endpoint: ADVOCATE_HARDSHIP_CLAIM_ENDPOINT
  it_behaves_like 'a claim create endpoint', relative_endpoint: ADVOCATE_HARDSHIP_CLAIM_ENDPOINT
end

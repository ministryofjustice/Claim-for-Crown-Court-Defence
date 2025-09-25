require 'rails_helper'

ADVOCATE_FINAL_CLAIM_ENDPOINT = 'advocates/final'.freeze
ADVOCATE_FINAL_VALIDATE_ENDPOINT = ClaimApiEndpoints.for(ADVOCATE_FINAL_CLAIM_ENDPOINT).validate

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::FinalClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  let(:claim_class)        { Claim::AdvocateClaim }
  let!(:provider)          { create(:provider) }
  let!(:vendor)            { create(:external_user, :admin, provider:) }
  let!(:advocate)          { create(:external_user, :advocate, provider:) }
  let!(:offence)           { create(:offence) }
  let!(:court)             { create(:court) }
  let(:trial_start_date)   { 1.year.ago }
  let(:retrial_start_date) { 6.months.ago }
  let(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_type_id: create(:case_type, :retrial).id,
      case_number: 'A20161234',
      first_day_of_trial: trial_start_date.as_json,
      estimated_trial_length: 10,
      actual_trial_length: 9,
      trial_concluded_at: (trial_start_date + 9.days).as_json,
      retrial_started_at: retrial_start_date.as_json,
      retrial_concluded_at: (retrial_start_date + 4.days).as_json,
      retrial_actual_length: '4',
      retrial_estimated_length: '5',
      retrial_reduction: 'true',
      advocate_category: 'Led junior',
      offence_id: offence.id,
      court_id: court.id,
      main_hearing_date: retrial_start_date.as_json
    }
  end

  after(:all) { clean_database }

  include_examples 'malformed or not iso8601 compliant dates',
                   action: :validate, attributes: %i[first_day_of_trial
                                                     trial_concluded_at
                                                     trial_fixed_notice_at
                                                     trial_fixed_at
                                                     trial_cracked_at
                                                     retrial_started_at
                                                     retrial_concluded_at
                                                     main_hearing_date],
                   relative_endpoint: ADVOCATE_FINAL_VALIDATE_ENDPOINT
  include_examples 'optional parameter validation',
                   optional_parameters: %i[estimated_trial_length
                                           actual_trial_length
                                           retrial_estimated_length
                                           retrial_actual_length
                                           main_hearing_date],
                   relative_endpoint: ADVOCATE_FINAL_VALIDATE_ENDPOINT
  it_behaves_like 'a claim endpoint', relative_endpoint: ADVOCATE_FINAL_CLAIM_ENDPOINT
  it_behaves_like 'a claim validate endpoint', relative_endpoint: ADVOCATE_FINAL_CLAIM_ENDPOINT
  it_behaves_like 'a claim create endpoint', relative_endpoint: ADVOCATE_FINAL_CLAIM_ENDPOINT
end

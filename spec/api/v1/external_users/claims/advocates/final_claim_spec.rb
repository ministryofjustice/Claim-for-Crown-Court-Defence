require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::FinalClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  FINAL_CLAIM_ENDPOINT = 'advocates/final'.freeze

  subject(:post_to_validate_endpoint) do
    post ClaimApiEndpoints.for(FINAL_CLAIM_ENDPOINT).validate, valid_params, format: :json
  end

  let(:claim_class)     { Claim::AdvocateClaim }
  let!(:provider)       { create(:provider) }
  let!(:vendor)         { create(:external_user, :admin, provider:) }
  let!(:advocate)       { create(:external_user, :advocate, provider:) }
  let!(:offence)        { create(:offence) }
  let!(:court)          { create(:court) }
  let!(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_type_id: create(:case_type, :retrial).id,
      case_number: 'A20161234',
      first_day_of_trial: '2015-01-01',
      estimated_trial_length: 10,
      actual_trial_length: 9,
      trial_concluded_at: '2015-01-09',
      retrial_started_at: '2015-02-01',
      retrial_concluded_at: '2015-02-05',
      retrial_actual_length: '4',
      retrial_estimated_length: '5',
      retrial_reduction: 'true',
      advocate_category: 'Led junior',
      offence_id: offence.id,
      court_id: court.id,
      main_hearing_date: '2015-02-05'
    }
  end

  after { clean_database }

  context 'when CLAIR contingency functionality is disabled' do
    before { valid_params.except!(:main_hearing_date) }

    include_examples 'advocate claim test setup'
    include_examples 'malformed or not iso8601 compliant dates',
                     action: :validate, attributes: %i[first_day_of_trial
                                                       trial_concluded_at
                                                       trial_fixed_notice_at
                                                       trial_fixed_at
                                                       trial_cracked_at
                                                       retrial_started_at
                                                       retrial_concluded_at]
    include_examples 'optional parameter validation',
                     optional_parameters: %i[estimated_trial_length
                                             actual_trial_length
                                             retrial_estimated_length
                                             retrial_actual_length]
    it_behaves_like 'a claim endpoint', relative_endpoint: FINAL_CLAIM_ENDPOINT
    it_behaves_like 'a claim validate endpoint', relative_endpoint: FINAL_CLAIM_ENDPOINT
    it_behaves_like 'a claim create endpoint', relative_endpoint: FINAL_CLAIM_ENDPOINT
  end

  context 'when CLAIR contingency functionality is enabled',
          skip: 'Skipped pending removal of the main_hearing_date feature flag' do
    include_examples 'advocate claim test setup'
    include_examples 'malformed or not iso8601 compliant dates',
                     action: :validate, attributes: %i[first_day_of_trial
                                                       trial_concluded_at
                                                       trial_fixed_notice_at
                                                       trial_fixed_at
                                                       trial_cracked_at
                                                       retrial_started_at
                                                       retrial_concluded_at
                                                       main_hearing_date]
    include_examples 'optional parameter validation',
                     optional_parameters: %i[estimated_trial_length
                                             actual_trial_length
                                             retrial_estimated_length
                                             retrial_actual_length
                                             main_hearing_date]
    it_behaves_like 'a claim endpoint', relative_endpoint: FINAL_CLAIM_ENDPOINT
    it_behaves_like 'a claim validate endpoint', relative_endpoint: FINAL_CLAIM_ENDPOINT
    it_behaves_like 'a claim create endpoint', relative_endpoint: FINAL_CLAIM_ENDPOINT
  end
end

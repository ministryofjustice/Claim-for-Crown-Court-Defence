require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::HardshipClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  ADVOCATE_HARDSHIP_CLAIM_ENDPOINT = 'advocates/hardship'.freeze

  let(:claim_class) { Claim::AdvocateHardshipClaim }
  let!(:provider)       { create(:provider) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor)         { create(:external_user, :admin, provider: provider) }
  let!(:advocate)       { create(:external_user, :advocate, provider: provider) }
  let!(:other_vendor)   { create(:external_user, :admin, provider: other_provider) }
  let!(:offence)        { create(:offence) }
  let!(:court)          { create(:court) }
  let!(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_stage_unique_code: FactoryBot.create(:case_stage, :trial_not_concluded).unique_code,
      case_number: 'A20201234',
      first_day_of_trial: '2020-01-01',
      trial_concluded_at: '2020-01-09',
      estimated_trial_length: 10,
      actual_trial_length: 9,
      advocate_category: 'Led junior',
      offence_id: offence.id,
      court_id: court.id
    }
  end

  after(:all) { clean_database }

  include_examples 'advocate claim test setup'
  it_behaves_like 'a claim endpoint', relative_endpoint: ADVOCATE_HARDSHIP_CLAIM_ENDPOINT
  it_behaves_like 'a claim validate endpoint', relative_endpoint: ADVOCATE_HARDSHIP_CLAIM_ENDPOINT
  it_behaves_like 'a claim create endpoint', relative_endpoint: ADVOCATE_HARDSHIP_CLAIM_ENDPOINT

  describe "POST #{ClaimApiEndpoints.for(ADVOCATE_HARDSHIP_CLAIM_ENDPOINT).validate}" do
    subject(:post_to_validate_endpoint) do
      post ClaimApiEndpoints.for(ADVOCATE_HARDSHIP_CLAIM_ENDPOINT).validate, valid_params, format: :json
    end

    it 'returns 200 when parameters that are optional for hardship claims are empty' do
      valid_params.delete(:last_day_of_trial)
      valid_params.delete(:estimated_trial_length)
      valid_params.delete(:actual_trial_length)
      post_to_validate_endpoint
      expect(last_response.status).to eq(200)
    end
  end
end

require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::InterimClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  INTERIM_CLAIM_ENDPOINT = 'advocates/interim'.freeze

  let(:claim_class) { Claim::AdvocateInterimClaim }
  let!(:provider) { create(:provider) }
  let!(:vendor) { create(:external_user, :admin, provider:) }
  let!(:advocate) { create(:external_user, :advocate, provider:) }
  let!(:offence) { create(:offence, :with_fee_scheme_ten) }
  let!(:court) { create(:court) }
  let(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: advocate.user.email,
      case_number: 'A20161234',
      advocate_category: 'Leading junior',
      offence_id: offence.id,
      court_id: court.id,
      main_hearing_date: '2015-02-05'
    }
  end

  after { clean_database }

  context 'when CLAIR contingency functionality is disabled' do
    before { valid_params.except!(:main_hearing_date) }

    include_examples 'advocate claim test setup'
    it_behaves_like 'a claim endpoint', relative_endpoint: INTERIM_CLAIM_ENDPOINT
    it_behaves_like 'a claim validate endpoint', relative_endpoint: INTERIM_CLAIM_ENDPOINT
    it_behaves_like 'a claim create endpoint', relative_endpoint: INTERIM_CLAIM_ENDPOINT
  end

  context 'when CLAIR contingency functionality is enabled',
          skip: 'Skipped pending removal of the main_hearing_date feature flag' do
    include_examples 'advocate claim test setup'
    it_behaves_like 'a claim endpoint', relative_endpoint: INTERIM_CLAIM_ENDPOINT
    it_behaves_like 'a claim validate endpoint', relative_endpoint: INTERIM_CLAIM_ENDPOINT
    it_behaves_like 'a claim create endpoint', relative_endpoint: INTERIM_CLAIM_ENDPOINT
  end
end

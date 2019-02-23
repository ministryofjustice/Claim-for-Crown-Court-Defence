require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::SupplementaryClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  SUPPLEMENTARY_CLAIM_ENDPOINT = 'advocates/supplementary'.freeze

  let(:claim_class) { Claim::AdvocateSupplementaryClaim }
  let!(:provider) { create(:provider) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor) { create(:external_user, :admin, provider: provider) }
  let!(:advocate) { create(:external_user, :advocate, provider: provider) }
  let!(:court) { create(:court)}
  let!(:valid_params) do
    {
      :api_key => provider.api_key,
      :creator_email => vendor.user.email,
      :advocate_email => advocate.user.email,
      :case_number => 'T20191234',
      :advocate_category => 'Leading junior',
      :court_id => court.id
    }
    end

  after(:all) { clean_database }

  include_examples 'test setup'
  it_behaves_like 'a claim endpoint', relative_endpoint: SUPPLEMENTARY_CLAIM_ENDPOINT
  it_behaves_like 'an advocate claim validate endpoint', relative_endpoint: SUPPLEMENTARY_CLAIM_ENDPOINT
  it_behaves_like 'an advocate claim create endpoint', relative_endpoint: SUPPLEMENTARY_CLAIM_ENDPOINT
end

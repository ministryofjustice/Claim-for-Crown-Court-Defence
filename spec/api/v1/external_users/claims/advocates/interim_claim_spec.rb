require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::Advocates::InterimClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  INTERIM_CLAIM_ENDPOINT = 'advocates/interim'.freeze

  let(:claim_class) { Claim::AdvocateInterimClaim }
  let!(:provider) { create(:provider) }
  let!(:other_provider) { create(:provider) }
  let!(:vendor) { create(:external_user, :admin, provider: provider) }
  let!(:advocate) { create(:external_user, :advocate, provider: provider) }
  let!(:offence) { create(:offence, :with_fee_scheme_ten)}
  let!(:court) { create(:court)}
  let!(:valid_params) do
    {
      :api_key => provider.api_key,
      :creator_email => vendor.user.email,
      :advocate_email => advocate.user.email,
      :case_number => 'A20161234',
      :advocate_category => 'Leading junior',
      :offence_id => offence.id,
      :court_id => court.id
    }
  end

  after(:all) { clean_database }

  describe 'vendor' do
    it 'should belong to same provider as advocate' do
      expect(vendor.provider).to eql(advocate.provider)
    end
  end

  include_examples 'sending non-permitted verbs', relative_endpoint: INTERIM_CLAIM_ENDPOINT
  include_examples 'POST to claim validate endpoint', relative_endpoint: INTERIM_CLAIM_ENDPOINT
  include_examples 'POST to claim create endpoint', relative_endpoint: INTERIM_CLAIM_ENDPOINT
end

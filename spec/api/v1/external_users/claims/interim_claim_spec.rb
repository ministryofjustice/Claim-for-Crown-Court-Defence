require 'rails_helper'

RSpec.describe API::V1::ExternalUsers::Claims::InterimClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  subject(:post_to_validate_endpoint) do
    post ClaimApiEndpoints.for(:interim).validate, valid_params, format: :json
  end

  let(:claim_class) { Claim::InterimClaim }
  let!(:provider)       { create(:provider, :lgfs) }
  let!(:other_provider) { create(:provider, :lgfs) }
  let!(:vendor)         { create(:external_user, :admin, provider:) }
  let!(:litigator)      { create(:external_user, :litigator, provider:) }
  let!(:other_vendor)   { create(:external_user, :admin, provider: other_provider) }
  let!(:offence)        { create(:offence, :miscellaneous) }
  let!(:court)          { create(:court) }
  let!(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: litigator.user.email,
      supplier_number: provider.lgfs_supplier_numbers.first.supplier_number,
      case_type_id: create(:case_type, :trial).id,
      case_number: 'A20161234',
      offence_id: offence.id,
      court_id: court.id,
      main_hearing_date: '2015-02-05'
    }
  end

  after(:all) { clean_database }

  include_examples 'litigator claim test setup'
  include_examples 'malformed or not iso8601 compliant dates', action: :validate, attributes: %i[main_hearing_date]
  include_examples 'optional parameter validation', optional_parameters: %i[main_hearing_date]
  it_behaves_like 'a claim endpoint', relative_endpoint: :interim
  it_behaves_like 'a claim validate endpoint', relative_endpoint: :interim
  it_behaves_like 'a claim create endpoint', relative_endpoint: :interim
end

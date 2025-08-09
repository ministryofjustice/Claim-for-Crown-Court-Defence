require 'rails_helper'

LITIGATOR_INTERIM_VALIDATE_ENDPOINT = ClaimApiEndpoints.for(:interim).validate

RSpec.describe API::V1::ExternalUsers::Claims::InterimClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  let(:claim_class)     { Claim::InterimClaim }
  let!(:provider)       { create(:provider, :lgfs) }
  let!(:vendor)         { create(:external_user, :admin, provider:) }
  let!(:litigator)      { create(:external_user, :litigator, provider:) }
  let!(:offence)        { create(:offence, :miscellaneous) }
  let!(:court)          { create(:court) }
  let(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: litigator.user.email,
      supplier_number: provider.lgfs_supplier_numbers.first.supplier_number,
      case_type_id: create(:case_type, :trial).id,
      case_number: 'A20161234',
      offence_id: offence.id,
      court_id: court.id,
      main_hearing_date: Time.zone.today.as_json
    }
  end

  after(:all) { clean_database }

  include_examples 'malformed or not iso8601 compliant dates', action: :validate,
                                                               attributes: %i[main_hearing_date],
                                                               relative_endpoint: LITIGATOR_INTERIM_VALIDATE_ENDPOINT
  include_examples 'optional parameter validation', optional_parameters: %i[main_hearing_date],
                                                    relative_endpoint: LITIGATOR_INTERIM_VALIDATE_ENDPOINT
  it_behaves_like 'a claim endpoint', relative_endpoint: :interim
  it_behaves_like 'a claim validate endpoint', relative_endpoint: :interim
  it_behaves_like 'a claim create endpoint', relative_endpoint: :interim
end

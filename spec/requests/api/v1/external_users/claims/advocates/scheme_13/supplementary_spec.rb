# frozen_string_literal: true

require 'requests/api/v1/external_users/claims/advocates/agfs_api_shared_examples'

RSpec.describe 'creating supplementary AGFS claim for fee scheme 13' do
  include_context 'with AGFS API users'

  let(:first_date) { Settings.agfs_scheme_13_clair_release_date.beginning_of_day }

  describe 'create new claim' do
    let(:endpoint) { ClaimApiEndpoints.for('advocates/supplementary') }

    let(:params) do
      default_params.merge(
        creator_email: vendor.email,
        user_email: advocate.email,
        case_number: 'A20181234',
        providers_ref: 'A20181234/1',
        cms_number: 'Meridian',
        advocate_category:,
        court_id: create(:court).id,
        additional_information: 'Bish \n bosh \n bash',
        prosecution_evidence: true
      )
    end

    include_examples 'claim with AGFS reform advocate categories'
  end
end

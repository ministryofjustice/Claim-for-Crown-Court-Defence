# frozen_string_literal: true

require 'requests/api/v1/external_users/claims/advocates/agfs_api_shared_examples'

RSpec.describe 'creating final AGFS claim for fee scheme 13' do
  include_context 'with AGFS API users'

  let(:first_date) { Settings.agfs_scheme_13_clair_release_date.beginning_of_day }

  describe 'create new claim' do
    let(:endpoint) { ClaimApiEndpoints.for('advocates/final') }

    let(:params) do
      default_params.merge(
        creator_email: vendor.email,
        user_email: advocate.email,
        case_type_id: create(:case_type, :trial).id,
        case_number: 'A20181234',
        providers_ref: 'A20181234/1',
        cms_number: 'Meridian',
        first_day_of_trial: first_date.as_json,
        estimated_trial_length: 10,
        actual_trial_length: 9,
        trial_concluded_at: (first_date + 9.days).as_json,
        advocate_category:,
        offence_id: create(:offence, :with_fee_scheme_thirteen).id,
        court_id: create(:court).id,
        additional_information: 'Bish bosh bash',
        prosecution_evidence: true
      )
    end

    include_examples 'AGFS reform advocate categories permitted'
    include_examples 'pre-AGFS reform advocate categories not permitted'
  end
end

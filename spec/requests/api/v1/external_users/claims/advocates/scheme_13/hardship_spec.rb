# frozen_string_literal: true

require 'requests/api/v1/external_users/claims/advocates/agfs_api_shared_examples'

RSpec.describe 'creating hardship AGFS claim for fee scheme 13' do
  include_context 'with AGFS API users'

  let(:first_date) { Settings.agfs_scheme_13_clair_release_date.beginning_of_day }

  describe 'create new claim' do
    let(:endpoint) { ClaimApiEndpoints.for('advocates/hardship') }

    let(:params) do
      default_params.merge(
        creator_email: vendor.email,
        user_email: advocate.email,
        case_stage_unique_code: create(:case_stage, :trial_not_concluded).unique_code,
        case_number: 'A20181234',
        first_day_of_trial: first_date.as_json,
        trial_concluded_at: (first_date + 9.days).as_json,
        estimated_trial_length: 10,
        actual_trial_length: 9,
        advocate_category:,
        offence_id: create(:offence, :with_fee_scheme_thirteen).id,
        court_id: create(:court).id
      )
    end

    include_examples 'claim with AGFS reform advocate categories'
    include_examples 'claim with pre-AGFS reform advocate categories'
  end
end

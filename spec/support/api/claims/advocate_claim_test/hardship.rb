require 'advocate_claim_test/base'

module AdvocateClaimTest
  class Hardship < Base
    def initialize(...)
      @claim_create_endpoint = 'claims/advocates/hardship'

      super
    end

    def test_creation!
      super

      # UPDATE basic fee
      @client.post_to_endpoint('fees', basic_fee_data)

      # CREATE miscellaneous fee
      response = @client.post_to_endpoint('fees', misc_fee_data)

      # add date attended to miscellaneous fee
      @attended_item_id = response['id']
      @client.post_to_endpoint('dates_attended', date_attended_data)

      # add expense
      @client.post_to_endpoint('expenses', expense_data)
    ensure
      clean_up
    end

    def claim_data
      super.merge(
        case_stage_unique_code: fetch_id(CASE_STAGE_ENDPOINT, key: 'unique_code', role: 'agfs'),
        first_day_of_trial: '2020-04-01',
        estimated_trial_length: 1,
        actual_trial_length: 1,
        trial_concluded_at: '2020-04-20',
        trial_fixed_notice_at: '2020-04-02',
        trial_fixed_at: '2020-04-04',
        trial_cracked_at: '2020-04-06',
        trial_cracked_at_third: 'first_third',
        offence_id: fetch_id(OFFENCE_ENDPOINT)
      )
    end
  end
end

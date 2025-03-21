require 'advocate_claim_test/base'

module AdvocateClaimTest
  class Final < Base
    def initialize(...)
      @claim_create_endpoint = 'claims/advocates/final'

      super
    end

    def test_creation!
      super

      # UPDATE basic fee
      @client.post_to_endpoint('fees', basic_fee_data)

      # CREATE miscellaneous fee
      response = @client.post_to_endpoint('fees', misc_fee_data)
      return if @client.failure

      # add date attended to miscellaneous fee
      @attended_item_id = response['id']
      @client.post_to_endpoint('dates_attended', date_attended_data)

      # add expense
      @client.post_to_endpoint('expenses', expense_data)
    ensure
      clean_up
    end

    def claim_data
      trial_start = (Time.zone.today - 30.days).next_weekday.strftime('%Y-%m-%d')

      super.merge(
        case_type_id: fetch_id(CASE_TYPE_ENDPOINT, index: 11, role: 'agfs'), # Trial
        first_day_of_trial: trial_start,
        estimated_trial_length: 1,
        actual_trial_length: 1,
        trial_concluded_at: (Time.zone.today - 29.days).next_weekday.strftime('%Y-%m-%d'),
        offence_id: fetch_id(OFFENCE_ENDPOINT),
        trial_fixed_notice_at: trial_start,
        trial_fixed_at: trial_start,
        trial_cracked_at: trial_start,
        trial_cracked_at_third: fetch_value(CRACKED_THIRD_ENDPOINT)
      )
    end
  end
end

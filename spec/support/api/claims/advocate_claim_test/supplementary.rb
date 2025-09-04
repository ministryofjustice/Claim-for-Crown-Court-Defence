require 'advocate_claim_test/base'

module AdvocateClaimTest
  class Supplementary < Base
    def initialize(...)
      @claim_create_endpoint = 'claims/advocates/supplementary'

      super
    end

    def test_creation!
      super

      # CREATE miscellaneous fee
      response = @client.post_to_endpoint('fees', misc_fee_data)
      return if @client.failure?

      # add date attended to miscellaneous fee
      @attended_item_id = response['id']
      @client.post_to_endpoint('dates_attended', date_attended_data)

      # add expense
      @client.post_to_endpoint('expenses', expense_data)
    ensure
      clean_up
    end

    def fee_type_options
      # Only certain misc fees are eligible e.g. Confiscation hearings (half day) - MIDTH
      super.merge(unique_code: 'MIDTH')
    end
  end
end

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

      # add date attended to miscellaneous fee
      @attended_item_id = response['id']
      @client.post_to_endpoint('dates_attended', date_attended_data)

      # add expense
      @client.post_to_endpoint('expenses', expense_data)
    ensure
      clean_up
    end

    def claim_data
      advocate_category = fetch_value(ADVOCATE_CATEGORY_ENDPOINT)
      court_id = fetch_id(COURT_ENDPOINT)

      {
        api_key:,
        creator_email: 'advocateadmin@example.com',
        advocate_email: 'advocate@example.com',
        case_number: 'B20161234',
        providers_ref: SecureRandom.uuid[3..15].upcase,
        advocate_category:,
        court_id:,
        cms_number: '12345678',
        additional_information: 'string',
        apply_vat: true
      }
    end

    def fee_type_options
      # Only certain misc fees are eligible e.g. Confiscation hearings (half day) - MIDTH
      super.merge(unique_code: 'MIDTH')
    end
  end
end

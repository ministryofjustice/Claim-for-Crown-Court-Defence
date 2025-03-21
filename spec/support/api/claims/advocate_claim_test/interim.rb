require 'advocate_claim_test/base'

module AdvocateClaimTest
  class Interim < Base
    def initialize(...)
      @claim_create_endpoint = 'claims/advocates/interim'

      super
    end

    def scheme_10_date
      @scheme_10_date ||= scheme_date_for('scheme 10')
    end

    def test_creation!
      super

      # CREATE warrant fee
      @client.post_to_endpoint('fees', warrant_fee_data)

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
      super.merge(
        case_number: 'S20161234', # Is it important to change this?
        offence_id: fetch_id(OFFENCE_ENDPOINT, rep_order_date: scheme_10_date)
      )
    end

    def representation_order_data
      super.merge(representation_order_date: scheme_10_date)
    end

    def warrant_fee_data
      fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, category: 'warrant', role: 'agfs_scheme_10')

      {
        api_key:,
        claim_id: @claim_uuid,
        fee_type_id:,
        warrant_issued_date: scheme_10_date,
        amount: 255.50
      }
    end

    def fee_type_options
      super.merge(role: 'agfs_scheme_10')
    end

    def date_attended_data
      super.merge(date: scheme_10_date, date_to: scheme_10_date)
    end

    def expense_data
      super.merge(date: scheme_10_date)
    end

    private

    def fetch_value(endpoint, index: nil, **)
      response = @client.get_dropdown_endpoint(endpoint, api_key:, role: 'agfs_scheme_10')
      index = rand(response.size) if index.nil?
      response[index]
    end
  end
end

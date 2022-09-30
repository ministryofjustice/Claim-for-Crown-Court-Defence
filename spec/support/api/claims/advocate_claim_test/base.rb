require 'base_claim_test'

module AdvocateClaimTest
  class Base < BaseClaimTest
    def initialize(...)
      @email = ADVOCATE_TEST_EMAIL
      @role = 'agfs'

      super
    end

    private

    def fee_type_options
      { role: 'agfs' }
    end

    def basic_fee_data
      fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, category: 'basic', **fee_type_options)

      {
        api_key:,
        claim_id: @claim_uuid,
        fee_type_id:,
        quantity: 1,
        rate: 255.50
      }
    end

    def misc_fee_data
      fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, category: 'misc', **fee_type_options)

      {
        api_key:,
        claim_id: @claim_uuid,
        fee_type_id:,
        quantity: 2,
        rate: 1.55
      }
    end

    def date_attended_data
      {
        api_key:,
        attended_item_id: @attended_item_id,
        attended_item_type: 'fee',
        date: '2015-06-01',
        date_to: '2015-06-01'
      }
    end
  end
end

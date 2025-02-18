require 'base_claim_test'

module LitigatorClaimTest
  class Base < BaseClaimTest
    def initialize(...)
      @email = LITIGATOR_TEST_EMAIL
      @role = 'lgfs'

      super
    end

    private

    def claim_data
      super.merge(
        creator_email: 'litigatoradmin@example.com',
        user_email: 'litigator@example.com',
        case_number: 'A20161234',
        supplier_number:,
        offence_id: fetch_id(OFFENCE_ENDPOINT, offence_description: 'Miscellaneous/other'),
        case_concluded_at: 1.month.ago.as_json,
        main_hearing_date: '2014-05-02'
      )
    end

    def graduated_fee_data
      fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, index: 5, category: 'graduated', role: 'lgfs') # Trial

      {
        api_key:,
        claim_id: @claim_uuid,
        fee_type_id:,
        quantity: 5,
        amount: 100.25,
        date: 1.month.ago.as_json
      }
    end

    def disbursement_data
      disbursement_type_id = fetch_id(DISBURSEMENT_TYPE_ENDPOINT)

      {
        api_key:,
        claim_id: @claim_uuid,
        disbursement_type_id:,
        net_amount: 100.25,
        vat_amount: 20.05
      }
    end
  end
end

require 'litigator_claim_test/base'

module LitigatorClaimTest
  class Interim < Base
    def initialize(...)
      @claim_create_endpoint = 'claims/interim'

      super
    end

    def test_creation!
      super

      # CREATE interim fee
      @client.post_to_endpoint('fees', interim_fee_data)

      # CREATE a disbursement
      @client.post_to_endpoint('disbursements', disbursement_data)
    ensure
      clean_up
    end

    def claim_data
      super.merge(
        case_type_id: fetch_id(CASE_TYPE_ENDPOINT, index: 12, role: 'lgfs'), # Trial
        effective_pcmh_date: 1.month.ago.as_json
      )
    end

    def interim_fee_data
      fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, index: 1, category: 'interim') # Effective PCMH

      {
        api_key:,
        claim_id: @claim_uuid,
        fee_type_id:,
        quantity: 5,
        amount: 200.50
      }
    end
  end
end

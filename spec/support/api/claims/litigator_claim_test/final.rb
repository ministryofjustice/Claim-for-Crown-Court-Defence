require 'litigator_claim_test/base'

module LitigatorClaimTest
  class Final < Base
    def initialize(...)
      @claim_create_endpoint = 'claims/final'

      super
    end

    def test_creation!
      super

      # CREATE graduated fee
      @client.post_to_endpoint('fees', graduated_fee_data)

      # CREATE miscellaneous fee
      @client.post_to_endpoint('fees', misc_fee_data)

      # CREATE a warrant fee
      @client.post_to_endpoint('fees', warrant_fee_data)

      # add expense
      @client.post_to_endpoint('expenses', expense_data)

      # CREATE a disbursement
      @client.post_to_endpoint('disbursements', disbursement_data)
    ensure
      clean_up
    end

    def claim_data
      super.merge(
        providers_ref: SecureRandom.uuid[3..15].upcase,
        case_type_id: fetch_id(CASE_TYPE_ENDPOINT, index: 12, role: 'lgfs'), # Trial
        actual_trial_length: 10
      )
    end

    def misc_fee_data
      fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, category: 'misc', role: 'lgfs') # Costs judge application

      {
        api_key:,
        claim_id: @claim_uuid,
        fee_type_id:,
        amount: 200.45
      }
    end

    def warrant_fee_data
      warrant_type_id = fetch_id(FEE_TYPE_ENDPOINT, category: 'warrant')

      {
        api_key:,
        claim_id: @claim_uuid,
        fee_type_id: warrant_type_id,
        warrant_issued_date: 3.months.ago.as_json,
        warrant_executed_date: 1.week.ago.as_json,
        amount: 100.25
      }
    end
  end
end

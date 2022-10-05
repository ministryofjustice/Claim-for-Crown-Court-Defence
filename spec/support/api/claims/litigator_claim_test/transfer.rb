require 'litigator_claim_test/base'

module LitigatorClaimTest
  class Transfer < Base
    def initialize(...)
      @claim_create_endpoint = 'claims/transfer'

      super
    end

    def test_creation!
      super

      # CREATE transfer fee
      @client.post_to_endpoint('fees', transfer_fee_data)

      # CREATE a disbursement
      @client.post_to_endpoint('disbursements', disbursement_data)
    ensure
      clean_up
    end

    def claim_data
      super.merge(
        case_type_id: fetch_id(CASE_TYPE_ENDPOINT, index: 12, role: 'lgfs'), # Trial
        'litigator_type' => 'new',
        'elected_case' => false,
        'transfer_stage_id' => fetch_id(TRANSFER_STAGES_ENDPOINT), # 10 - Up to and including PCMH transfer
        'transfer_date' => 1.month.ago.as_json,
        'case_conclusion_id' => fetch_id(TRANSFER_CASE_CONCLUSIONS_ENDPOINT, index: 4) # 50 - Guilty plea
      )
    end

    def transfer_fee_data
      fee_type_id = fetch_id(FEE_TYPE_ENDPOINT, category: 'transfer')

      {
        api_key:,
        claim_id: @claim_uuid,
        fee_type_id:, # Transfer
        amount: 150.25
      }
    end
  end
end

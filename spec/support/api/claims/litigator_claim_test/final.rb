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
      case_type_id = fetch_id(CASE_TYPE_ENDPOINT, index: 12, role: 'lgfs') # Trial
      offence_id = fetch_id(OFFENCE_ENDPOINT, offence_description: 'Miscellaneous/other')
      court_id = fetch_id(COURT_ENDPOINT)

      {
        api_key:,
        creator_email: 'litigatoradmin@example.com',
        user_email: 'litigator@example.com',
        case_number: 'A20161234',
        providers_ref: SecureRandom.uuid[3..15].upcase,
        supplier_number:,
        case_type_id:,
        offence_id:,
        court_id:,
        cms_number: '12345678',
        additional_information: 'string',
        case_concluded_at: 1.month.ago.as_json,
        actual_trial_length: 10
      }
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

require 'litigator_claim_test/base'

module LitigatorClaimTest
  class Hardship < Base
    def initialize(...)
      @claim_create_endpoint = 'claims/litigators/hardship'

      super
    end

    def test_creation!
      super

      # CREATE graduated fee
      @client.post_to_endpoint('fees', graduated_fee_data)
    ensure
      clean_up
    end

    def claim_data
      offence_id = fetch_id(OFFENCE_ENDPOINT, offence_description: 'Miscellaneous/other')
      court_id = fetch_id(COURT_ENDPOINT)

      {
        api_key:,
        creator_email: 'litigatoradmin@example.com',
        user_email: 'litigator@example.com',
        case_number: 'A20201234',
        supplier_number:,
        case_stage_unique_code: 'PREPTPHADJ',
        offence_id:,
        court_id:,
        cms_number: '12345678',
        additional_information: 'string',
        effective_pcmh_date: 1.month.ago.as_json
      }
    end
  end
end

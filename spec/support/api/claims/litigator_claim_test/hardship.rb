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
      super.merge(case_stage_unique_code: 'PREPTPHADJ')
    end
  end
end

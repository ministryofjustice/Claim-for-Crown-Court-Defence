module Claim
  class LitigatorSupplierNumberValidator < Claim::BaseClaimValidator
    include Claim::LitigatorSupplierNumberValidations

    def self.fields_for_steps
      {
        case_details: first_step_common_validations
      }
    end
  end
end

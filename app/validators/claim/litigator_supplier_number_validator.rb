class Claim::LitigatorSupplierNumberValidator < Claim::BaseClaimValidator
  include Claim::LitigatorSupplierNumberValidations

  def self.fields_for_steps
    [
      [first_step_common_validations]
    ]
  end
end

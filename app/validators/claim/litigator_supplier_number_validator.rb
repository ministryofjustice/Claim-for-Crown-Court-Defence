class Claim::LitigatorSupplierNumberValidator < Claim::BaseClaimValidator
  include Claim::LitigatorSupplierNumberValidations

  def self.fields_for_steps
    {
      case_details: first_step_common_validations
    }.with_indifferent_access
  end
end

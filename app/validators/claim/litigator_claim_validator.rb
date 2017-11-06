class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    [
      [].unshift(first_step_common_validations), # case_details
      %i[
      ], # defendants
      %i[
        offence
      ], # offence details
      %i[
        actual_trial_length
        total
      ] # fees (why is actual trial length validated here)
    ]
  end
end

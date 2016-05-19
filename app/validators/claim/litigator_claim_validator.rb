class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    [
      [].unshift(first_step_common_validations),
      [
        :actual_trial_length,
        :total
      ]
    ]
  end
end

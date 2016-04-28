class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    [
      [
        :case_type,
        :court,
        :case_number,
        :advocate_category,
        :offence,
        :case_concluded_at
      ],
      [
        :estimated_trial_length,
        :actual_trial_length,
        :retrial_estimated_length,
        :retrial_actual_length,
        :first_day_of_trial,
        :trial_concluded_at,
        :retrial_started_at,
        :retrial_concluded_at,
        :total
      ]
    ]
  end
end

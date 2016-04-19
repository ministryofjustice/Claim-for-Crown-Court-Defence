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
        :trial_cracked_at_third,
        :trial_fixed_notice_at,
        :trial_fixed_at,
        :trial_cracked_at,
        :first_day_of_trial,
        :trial_concluded_at,
        :retrial_started_at,
        :retrial_concluded_at,
        :total
      ]
    ]
  end
end

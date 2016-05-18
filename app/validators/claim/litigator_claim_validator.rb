class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    [
      [
        :case_type,
        :court,
        :case_number,
        :transfer_case_number,
        :advocate_category,
        :offence,
        :case_concluded_at
      ],
      [
        :actual_trial_length,
        :total
      ]
    ]
  end
end

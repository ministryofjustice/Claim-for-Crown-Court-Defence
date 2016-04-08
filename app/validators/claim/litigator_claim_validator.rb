class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator

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

  private

  def validate_creator
    super if defined?(super)
    validate_has_role(@record.creator.try(:provider), :lgfs, :creator, 'must be from a provider with permission to submit LGFS claims')
  end

  def validate_advocate_category
    validate_absence(:advocate_category, "invalid")
  end

  def validate_offence
    validate_presence(:offence, "blank")
    validate_inclusion(:offence, Offence.miscellaneous.to_a, "invalid")
  end

  def validate_case_concluded_at
    validate_presence(:case_concluded_at, 'blank')
  end
end

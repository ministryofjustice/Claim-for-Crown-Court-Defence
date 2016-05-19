class Claim::AdvocateClaimValidator < Claim::BaseClaimValidator

  def self.fields_for_steps
    [
      [
        :case_type,
        :court,
        :case_number,
        :transfer_court,
        :transfer_case_number,
        :advocate_category,
        :offence,
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
        :case_concluded_at
      ],
      [
        :total
      ]
    ]
  end

  private

  def supplier_number_regex
    ExternalUser::SUPPLIER_NUMBER_REGEX
  end

  def validate_creator
    super if defined?(super)
    validate_has_role(@record.creator.try(:provider), :agfs, :creator, 'must be from a provider with permission to submit AGFS claims')
  end

  def validate_advocate_category
    validate_presence(:advocate_category, "blank")
    validate_inclusion(:advocate_category, Settings.advocate_categories, "Advocate category must be one of those in the provided list") unless @record.advocate_category.blank?
  end

  def validate_offence
    validate_presence(:offence, "blank") unless fixed_fee_case?
  end

  def validate_case_concluded_at
    validate_absence(:case_concluded_at, 'present')
  end

  def validate_supplier_number
    validate_pattern(:supplier_number, supplier_number_regex, 'invalid')
  end
end

class Claim::AdvocateClaimValidator < Claim::BaseClaimValidator

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
    validate_absence(:case_concluded_at, 'presence')
  end
end

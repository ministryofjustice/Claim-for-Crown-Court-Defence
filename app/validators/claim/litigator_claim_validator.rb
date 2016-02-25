class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  # TODO: implement LitigatorClaim specific validation

  def validate_external_user
    super if defined?(super)
    validate_has_role(@record.external_user, :litigator, :external_user, 'must have litigator role')
  end

  def validate_creator
    super if defined?(super)
    validate_has_role(@record.creator.provider, :lgfs, :creator, 'must be from a provider with permission to submit LGFS claims')
  end

  def validate_advocate_category
    validate_absence(:advocate_category, "invalid")
  end

  def validate_offence
    validate_presence(:offence, "blank")
    validate_inclusion(:offence, Offence.miscellaneous.to_a, "invalid")
  end

end
class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  # TODO: implement LitigatorClaim specific validation

  def validate_external_user
    validate_has_role(@record.external_user, :litigator, :external_user, 'must have litigator role')
    super
  end


  def validate_creator
    validate_has_role(@record.creator.provider, :lgfs, :creator, 'must be from a provider with the LGFS fee scheme')
    super
  end
end
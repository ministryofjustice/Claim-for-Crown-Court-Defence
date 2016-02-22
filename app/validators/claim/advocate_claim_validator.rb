class Claim::AdvocateClaimValidator < Claim::BaseClaimValidator
  
 # ALWAYS required/mandatory
  def validate_external_user
    validate_has_role(@record.external_user, :advocate, :external_user, 'must have advocate role')
    super
  end

  def validate_creator
    validate_has_role(@record.creator.try(:provider), :agfs, :creator, 'must be from a Provider that has AGFS fee scheme')
    super
  end
end

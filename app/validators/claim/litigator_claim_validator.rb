class Claim::LitigatorClaimValidator < Claim::BaseClaimValidator
  # TODO: implement LitigatorClaim specific validation

  def validate_external_user
    unless @record.external_user.nil?
      unless @record.external_user.is?(:litigator)
        @record.errors[:external_user] << 'External user must have litigator role'
      end
    end
    super
  end


  def validate_creator
    unless @record.creator.nil?
      unless @record.creator.provider.is?(:lgfs)
        @record.errors[:creator] << "Creator must be from a Provider that has LGFS fee scheme"
      end
    end
    super
  end
end
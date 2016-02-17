class Claim::AdvocateClaimValidator < Claim::BaseClaimValidator
  
 # ALWAYS required/mandatory
  def validate_external_user
    unless @record.external_user.nil?
      unless @record.external_user.is?(:advocate)
        @record.errors[:external_user] << 'External user must have advocate role'
      end
    end
    super
  end

  def validate_creator
    unless @record.creator.nil?
      unless @record.creator.provider.is?(:agfs)
        @record.errors[:creator] << "Creator must be from a Provider that has AGFS fee scheme"
      end
    end
    super
  end

end

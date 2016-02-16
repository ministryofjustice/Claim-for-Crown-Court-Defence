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

end

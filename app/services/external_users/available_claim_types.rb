module ExternalUsers
  class AvailableClaimTypes
    def self.call(context)
      claim_types = []

      if context.is_a? Provider
        claim_types << Claim::AdvocateClaim if context.agfs?
        claim_types.concat [ Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim ] if context.lgfs?
      else
        context.roles.each do |role|
          claim_types = [ Claim::AdvocateClaim, *litigator_claim_types ] if role == 'admin'
          claim_types.concat [ Claim::AdvocateClaim ] if role == 'advocate'
          claim_types.concat litigator_claim_types if role == 'litigator'
        end
      end

      claim_types.uniq
    end

    def self.litigator_claim_types
      litigator_claim_types = [Claim::LitigatorClaim]
      litigator_claim_types << Claim::InterimClaim if Settings.allow_lgfs_interim_fees?
      litigator_claim_types << Claim::TransferClaim if Settings.allow_lgfs_transfer_fees?
      litigator_claim_types
    end
  end
end

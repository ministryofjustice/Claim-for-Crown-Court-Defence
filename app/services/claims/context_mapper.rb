module Claims
  class ContextMapper
    # Class to map provider roles and user roles to claim contexts
    # i.e. the provider and external user role combine to
    #      determine what claims the user can both view and create
    #

    def initialize(external_user, options = {})
      @external_user = external_user
      @provider = external_user.provider
      @scheme_filter = options[:scheme] || :all
    end

    def available_claim_types
      hardship_types = [Claim::AdvocateHardshipClaim, Claim::LitigatorHardshipClaim]
      @available_claim_types ||= @external_user.available_claim_types & @external_user.provider.available_claim_types
      @available_claim_types.tap do |arr|
        arr.delete_if { |el| hardship_types.include?(el) } unless Settings.hardship_claims_enabled?
        arr.delete_if { |el| el.eql?(Claim::LitigatorHardshipClaim) } unless Settings.lgfs_hardship_claims_enabled?
      end
    end

    def available_schemes
      [].tap do |schemes|
        schemes.push(:agfs) if available_claim_types.any?(&:agfs?)
        schemes.push(:lgfs) if available_claim_types.any?(&:lgfs?)
      end
    end

    def available_comprehensive_claim_types
      available_claim_types.map { |claim_type| comprehensive_claim_type_for(claim_type) }.compact
    end

    def available_claims
      claims = @external_user.admin? ? @provider.claims : @external_user.claims
      claims.send(@scheme_filter)
    end

    private

    def comprehensive_claim_type_for(claim_type)
      {
        'Claim::AdvocateClaim' => 'agfs',
        'Claim::AdvocateInterimClaim' => 'agfs_interim',
        'Claim::AdvocateSupplementaryClaim' => 'agfs_supplementary',
        'Claim::AdvocateHardshipClaim' => 'agfs_hardship',
        'Claim::LitigatorClaim' => 'lgfs_final',
        'Claim::InterimClaim' => 'lgfs_interim',
        'Claim::TransferClaim' => 'lgfs_transfer',
        'Claim::LitigatorHardshipClaim' => 'lgfs_hardship'
      }[claim_type.to_s]
    end
  end
end

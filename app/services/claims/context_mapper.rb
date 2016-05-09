module Claims
  class ContextMapper

    # Class to map provider roles and user roles to claim contexts
    # i.e. the provider and external user role combine to
    #      determine what claims the user can both view and create
    #

    def initialize(external_user)
      @external_user = external_user
      @provider = external_user.provider
    end

    def available_claim_types
      ExternalUsers::AvailableClaimTypes.call(@external_user) & ExternalUsers::AvailableClaimTypes.call(@external_user.provider)
    end

    def available_claims
      @external_user.admin? ? @provider.claims : @external_user.claims
    end

  end
end

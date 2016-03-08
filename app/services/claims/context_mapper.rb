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
      claim_types = []
      claim_types <<  if @external_user.provider.has_roles?('agfs') # provider ONLY agfs
                        Claim::AdvocateClaim
                      elsif @external_user.provider.has_roles?('lgfs') # provider ONLY lgfs
                        Claim::LitigatorClaim
                      elsif @external_user.provider.has_roles?('agfs','lgfs') # provider has agfs and lgfs privileges
                        if @external_user.has_roles?('admin') || @external_user.has_roles?('admin','advocate','litigator')
                          [Claim::AdvocateClaim, Claim::LitigatorClaim]
                        elsif @external_user.has_roles?('litigator') || @external_user.has_roles?('admin','litigator')
                          Claim::LitigatorClaim
                        elsif @external_user.has_roles?('advocate') || @external_user.has_roles?('admin','advocate')
                          Claim::AdvocateClaim
                        end
                      end
      claim_types.flatten
    end

    def available_claims
      if @provider.has_roles?('agfs') && @external_user.admin? #NOTE: agfs order is important as admin supercedes advocate
        @provider.claims
      elsif @provider.has_roles?('agfs') && @external_user.advocate?
        @external_user.claims
      elsif @provider.has_roles?('lgfs') && (@external_user.litigator? || @external_user.admin?)
        @provider.claims_created
      elsif @provider.has_roles?('agfs','lgfs') && @external_user.has_roles?('advocate','admin') #advocate adminstrator (only) in "firm"
        @provider.claims
      elsif @provider.has_roles?('agfs','lgfs') && @external_user.has_roles?('litigator','admin') #litigator administrator (only) in "firm"
        @provider.claims_created
      elsif @provider.has_roles?('agfs','lgfs') && ( @external_user.has_roles?('admin') || @external_user.has_roles?('advocate','litigator','admin') ) #advocate and litigator admin in "firm"
        @provider.claims_created.merge!(@provider.claims)
      end
    end

  end
end

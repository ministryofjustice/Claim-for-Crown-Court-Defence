module Claims
  class FetchEligibleOffences
    def self.for(claim)
      new(claim).call
    end

    def initialize(claim)
      @claim = claim
    end

    def call
      return eligible_offences if using_fee_reform?
      default_offences
    end

    private

    attr_reader :claim

    def using_fee_reform?
      claim.agfs? &&
        FeatureFlag.active?(:agfs_fee_reform) &&
        claim.fee_scheme == 'fee_reform'
    end

    def eligible_offences
      # TODO: Depends on Fee Scheme 10 SPIKE work
      # 1. Checks fee scheme associated with claim
      # 2. Retrieves list of offences associated with that fee scheme
      # 3. If claim already has an associated offence return list only with that offence
      [:todo]
    end

    def default_offences
      # TODO: Eventually they will need to be scoped by fee scheme 9
      # which currently does not exist
      if claim.offence
        [claim.offence]
      else
        Offence.in_scheme_nine
      end
    end
  end
end

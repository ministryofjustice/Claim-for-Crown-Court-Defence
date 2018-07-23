module Claims
  class FetchEligibleOffences
    def self.for(claim)
      new(claim).call
    end

    def initialize(claim)
      @claim = claim
    end

    def call
      return agfs_reform_offences if claim.agfs_reform?
      default_offences
    end

    private

    attr_reader :claim

    def agfs_reform_offences
      Offence.unscoped.in_scheme_ten
             .joins(offence_band: :offence_category)
             .includes(offence_band: :offence_category)
             .group('offences.description, offences.id, offence_bands.id, offence_categories.id')
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

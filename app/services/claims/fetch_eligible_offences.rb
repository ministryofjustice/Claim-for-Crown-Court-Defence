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
      fee_scheme_offences
        .joins(offence_band: :offence_category)
        .includes(offence_band: :offence_category)
        .group('offences.description, offences.id, offence_bands.id, offence_categories.id')
    end

    def fee_scheme_offences
      Offence.unscoped.send(:"in_scheme_#{claim.fee_scheme.version}")
    end

    def default_offences
      if claim.offence
        [claim.offence]
      else
        Offence.in_scheme_nine
      end
    end
  end
end

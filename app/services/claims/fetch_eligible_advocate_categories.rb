module Claims
  class FetchEligibleAdvocateCategories
    def self.for(claim)
      new(claim).call
    end

    def initialize(claim)
      @claim = claim
    end

    def call
      return unless claim&.agfs?
      return all_categories unless claim.fee_scheme
      return agfs_reform_categories if agfs_reform?
      default_categories
    end

    private

    attr_reader :claim

    def default_categories
      Settings.advocate_categories
    end

    def agfs_reform_categories
      Settings.agfs_reform_advocate_categories
    end

    def all_categories
      (default_categories + agfs_reform_categories).uniq
    end

    # TODO: remove the Offence check from here as this should already
    # be handled by FeeScheme.for_claim called by agfs_reform?
    def agfs_reform?
      claim.agfs_reform? || Offence.in_scheme_ten.include?(claim.offence)
    end
  end
end

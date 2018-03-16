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
      return fee_reform_categories if using_fee_reform?
      default_categories
    end

    private

    attr_reader :claim

    def default_categories
      Settings.advocate_categories
    end

    def fee_reform_categories
      Settings.agfs_reform_advocate_categories
    end

    def using_fee_reform?
      claim.fee_scheme == 'fee_reform'
    end
  end
end

module Claims
  class FetchEligibleMiscFeeTypes
    def initialize(claim)
      if claim.nil? || claim&.interim?
        @filter = Claims::FetchEligibleMiscFeeTypes::NullFilter.new
      elsif claim.agfs?
        @filter = Claims::FetchEligibleMiscFeeTypes::Agfs.new(claim)
      elsif claim.lgfs?
        @filter = Claims::FetchEligibleMiscFeeTypes::Lgfs.new(claim)
      end
    end

    def call
      @filter.call
    end
  end
end

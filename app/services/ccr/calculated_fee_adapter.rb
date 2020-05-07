module CCR
  class CalculatedFeeAdapter
    attr_reader :hardship_claim

    def initialize(hardship_claim)
      @hardship_claim = hardship_claim
    end

    class << self
      def ex_vat_for(hardship_claim)
        adapter = new(hardship_claim)
        adapter.ex_vat
      end
    end

    def ex_vat
      @hardship_claim.basic_fees.inject(0) do |sum, basic_fee|
        sum + basic_fee.amount
      end
    end
  end
end

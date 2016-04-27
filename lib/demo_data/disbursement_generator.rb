module DemoData

  class DisbursementGenerator

    def initialize(claim = nil)
      @claim = claim
    end

    def generate!(range = 0..2)
      DisbursementType.order('RANDOM()').first(rand(range)).map { |type| add_disbursement(type) }
    end

    private

    def add_disbursement(type)
      Disbursement.create(claim: @claim, disbursement_type: type,
                          net_amount: rand(100.0..999.99).round(2),
                          vat_amount: rand(0.0..99.99).round(2))
    end

  end
end

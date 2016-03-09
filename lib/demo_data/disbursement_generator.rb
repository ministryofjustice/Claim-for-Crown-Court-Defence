module DemoData

  class DisbursementGenerator

    def initialize(claim)
      @claim = claim
    end

    def generate!
      DisbursementType.order('RANDOM()').first(rand(0..5)).each { |type| add_disbursement(type) }
    end

    private

    def add_disbursement(type)
      Disbursement.create(claim: @claim, disbursement_type: type, net_amount: rand(1.0..99.99).round(2), vat_amount: rand(0.0..15.0).round(2))
    end

  end
end

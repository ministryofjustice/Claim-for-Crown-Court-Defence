module DemoData

  class DisbursementGenerator

    def initialize(claim)
      @claim = claim
    end

    def generate!
      DisbursementType.order('RANDOM()').first(rand(0..2)).each { |type| add_disbursement(type) }
    end

    private

    def add_disbursement(type)
      vat_amount = @claim.vat_registered? ? rand(0.0..15.0).round(2) : 0.0
      Disbursement.create(claim: @claim, disbursement_type: type, net_amount: rand(1.0..99.99).round(2), vat_amount: vat_amount)
    end

  end
end

module DemoData

  class FeeGenerator

    # Call as FeeGenerator.new(claim, :fixed)  or FeeGenerator.new(claim, :misc)
    #
    def initialize(claim, misc_or_fixed)
      @claim       = claim
      @fee_types   = FeeType.send(misc_or_fixed)
      @codes_added = []
    end

    def generate!
      rand(1..3).times { add_fee }
    end

    private

    def add_fee
      fee_type = @fee_types.sample
      while @codes_added.include?(fee_type.code)
        fee_type = @fee_types.sample
      end
      Fee.create(claim: @claim, fee_type: fee_type, quantity: rand(1..10), amount: rand(100..900))
      @codes_added << fee_type.code
    end
  
  end
end




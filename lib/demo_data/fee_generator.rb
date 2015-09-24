module DemoData

  class FeeGenerator

    # Call as FeeGenerator.new(claim, :fixed)  or FeeGenerator.new(claim, :misc)
    #
    def initialize(claim, misc_or_fixed)
      @claim       = claim
      @fees        = FeeType.send(misc_or_fixed)
      @codes_added = []
    end

    def generate!
      rand(0..3).times { add_fee }
    end

    private

    def add_fee
      fee_type = @fees.sample
      while @codes_added.include?(fee_type.code)
        fee_type = @fees.sample
      end
      fee = FactoryGirl.create :fee, fee_type: fee_type, claim: @claim, quantity: rand(0..10), amount: rand(100..900)
      @codes_added << fee_type.code
    end
  
  end
end




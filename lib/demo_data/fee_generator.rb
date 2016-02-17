module DemoData

  class FeeGenerator

    # Call as FeeGenerator.new(claim, :fixed) or FeeGenerator.new(claim, :misc)
    #
    def initialize(claim, fee_type_class)
      @claim          = claim
      @fee_types      = fee_type_class.all
      @codes_added    = []
      @fee_type_class = fee_type_class
      @fee_class      = derive_fee_class_from_fee_type_class
    end

    def generate!
      rand(1..3).times { add_fee }
    end

    private

    def add_fee
      fee_type = @fee_types.where(calculated: true).sample
      while @codes_added.include?(fee_type.code)
        fee_type = @fee_types.sample
      end
      @fee_class.create(claim: @claim, fee_type: fee_type, quantity: rand(1..10), rate: rand(25..75).round(2))
      @codes_added << fee_type.code
    end

    def derive_fee_class_from_fee_type_class
      @fee_type_class.to_s.sub(/Type$/,'').constantize
    end

  end
end




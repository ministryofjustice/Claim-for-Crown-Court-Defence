module DemoData
  class FeeGenerator

    # Call as FeeGenerator.new(claim, :fixed) or FeeGenerator.new(claim, :misc)
    #
    def initialize(claim, fee_type_class, fee_types = nil)
      @claim          = claim
      if @claim.agfs?
        @fee_types      = fee_types || fee_type_class.agfs
      else
        @fee_types = Fee::MiscFeeType.lgfs.where(unique_code: %w[MICJA MICJP MIEVI MISPF])
      end
      @codes_added    = []
      @fee_type_class = fee_type_class
      @fee_class      = derive_fee_class_from_fee_type_class
    end

    def generate!
      rand(1..3).times { add_fee }
    end

    private

    def add_fee
      if @claim.agfs?
        fee_type = validatable_agfs_fee_types.sample
        while @codes_added.include?(fee_type.code)
          fee_type = validatable_agfs_fee_types.sample
        end
        @fee_class.create(claim: @claim, fee_type: fee_type, quantity: rand(1..10), rate: rand(25..75).round(2))
      else
        fee_type = @fee_types.sample
        while @codes_added.include?(fee_type.code)
          fee_type = validatable_lgfs_misc_fee_types.sample
        end
        @fee_class.create(claim: @claim, fee_type: fee_type, amount: rand(25..75).round(2))
      end
      @codes_added << fee_type.code
    end

    def derive_fee_class_from_fee_type_class
      @fee_type_class.to_s.sub(/Type$/,'').constantize
    end

    # avoid defendant uplifts for simplicities sake
    # as claim must have a matching number of defendants
    # and they are uncommon
    #
    def validatable_agfs_fee_types
      @fee_types.select do |fee_type|
        fee_type.calculated == true && !fee_type.defendant_uplift?
      end
    end

    def validatable_lgfs_misc_fee_types
      @fee_types
    end
  end
end

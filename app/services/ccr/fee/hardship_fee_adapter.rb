require_relative 'basic_fee_adaptable'

module CCR
  module Fee
    class HardshipFeeAdapter < SimpleBillAdapter
      acts_as_simple_bill bill_type: 'AGFS_ADVANCE', bill_subtype: 'AGFS_HARDSHIP'

      include BasicFeeAdaptable
    end
  end
end

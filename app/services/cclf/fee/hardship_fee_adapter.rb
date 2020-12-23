module CCLF
  module Fee
    class HardshipFeeAdapter < SimpleBillAdapter
      acts_as_simple_bill bill_type: 'FEE_ADVANCE', bill_subtype: 'HARDSHIP'
    end
  end
end

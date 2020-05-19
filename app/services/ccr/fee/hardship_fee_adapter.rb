module CCR
  module Fee
    class HardshipFeeAdapter < SimpleBillAdapter
      include FeeAdaptations
      acts_as_simple_bill bill_type: 'AGFS_ADVANCE', bill_subtype: 'AGFS_HARDSHIP'
    end
  end
end

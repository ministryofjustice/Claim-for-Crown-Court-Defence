module CCR
  module Fee
    class WarrantFeeAdapter < SimpleBillAdapter
      acts_as_simple_bill bill_type: 'AGFS_ADVANCE', bill_subtype: 'AGFS_WARRANT'
    end
  end
end

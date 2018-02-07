module CCLF
  module Fee
    class WarrantFeeAdapter < SimpleBillAdapter
      acts_as_simple_bill bill_type: 'FEE_ADVANCE', bill_subtype: 'WARRANT', vat_included: false
    end
  end
end

module CCLF
  module Fee
    class LitigatorFeeAdapter < SimpleBillAdapter
      acts_as_simple_bill bill_type: 'LIT_FEE', bill_subtype: 'LIT_FEE', vat_included: false
    end
  end
end

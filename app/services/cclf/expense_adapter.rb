module CCLF
  class ExpenseAdapter < SimpleBillAdapter
    acts_as_simple_bill bill_type: 'DISBURSEMENT', bill_subtype: 'TRAVEL COSTS'
  end
end

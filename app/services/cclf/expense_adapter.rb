module CCLF
  class ExpenseAdapter < SimpleBillAdapter
    def bill_type
      'DISBURSEMENT'
    end

    def bill_subtype
      'TRAVEL COSTS'
    end
  end
end

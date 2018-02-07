module CCLF
  class ExpenseAdapter < SimpleBillAdapter
    acts_as_simple_bill bill_type: 'DISBURSEMENT', bill_subtype: 'TRAVEL COSTS'

    def total
      amount + vat_amount
    end

    # since we are summing amount and vat_amount, vat can always be considered to be included
    def vat_included
      true
    end
  end
end

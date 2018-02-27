module API
  module Entities
    module CCLF
      class TransferClaim < BaseClaim
        # TODO: WIP - all bills must be addeded
        def bills
          data = []
          data.push AdaptedTransferFee.represent(object.transfer_fee)
          data.push AdaptedMiscFee.represent(object.misc_fees)
          data.push AdaptedDisbursement.represent(object.disbursements)
          data.push AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end
      end
    end
  end
end

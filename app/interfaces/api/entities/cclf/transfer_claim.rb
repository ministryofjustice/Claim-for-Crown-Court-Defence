module API
  module Entities
    module CCLF
      class TransferClaim < BaseClaim
        # TODO: WIP - all bills must be addeded
        def bills
          data = []
          # data.push API::Entities::CCLF::AdaptedFixedFee.represent(fixed_fees)
          # data.push API::Entities::CCLF::AdaptedGraduatedFee.represent(graduated_fees)
          # data.push API::Entities::CCLF::AdaptedMiscFee.represent(miscellaneous_fees)
          # data.push API::Entities::CCLF::AdaptedDisbursments.represent(disbursements)
          # data.push API::Entities::CCLF::AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end
      end
    end
  end
end

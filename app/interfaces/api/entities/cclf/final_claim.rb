module API
  module Entities
    module CCLF
      class FinalClaim < BaseClaim
        # TODO: WIP - all bills must be addeded
        def bills
          data = []
          data.push AdaptedFixedFee.represent(object.fixed_fee) if object.fixed_fee.present?
          data.push AdaptedGraduatedFee.represent(object.graduated_fee) if object.graduated_fee.present?
          # data.push API::Entities::CCLF::AdaptedMiscFee.represent(miscellaneous_fees)
          # data.push API::Entities::CCLF::AdaptedDisbursments.represent(disbursements)
          # data.push API::Entities::CCLF::AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end
      end
    end
  end
end

module API
  module Entities
    module CCR
      class InterimClaim < BaseClaim
        expose :dummy_case_type, as: :case_type, using: API::Entities::CCR::CaseType
        expose :offence, using: API::Entities::CCR::Offence

        private

        def bills
          data = []
          data.push AdaptedWarrantFee.represent(object.warrant_fee)
          data.push AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end
      end
    end
  end
end

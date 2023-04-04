module API
  module Entities
    module CCR
      class SupplementaryClaim < BaseClaim
        expose :dummy_case_type, as: :case_type, using: API::Entities::CCR::CaseType
        expose :dummy_first_day_of_trial, as: :first_day_of_trial

        private

        # TODO: try to get the adapter component into the adapted_misc_fee entity
        # but will need to handle claimability (i.e. must have values
        # be mappable - adefendant uplifts [and case uplifts?] not included)
        def bills
          data = []
          data.push AdaptedMiscFee.represent(miscellaneous_fees)
          data.push AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end
      end
    end
  end
end

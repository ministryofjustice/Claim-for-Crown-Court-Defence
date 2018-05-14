module API
  module Entities
    module CCR
      class AdvocateInterimClaim < BaseEntity
        # TODO: find common functionality with advocate "final" claim and promote to CCR::BaseClaim class
        #
        expose :uuid
        expose :supplier_number
        expose :case_number

        expose  :last_submitted_at,
                format_with: :utc

        expose :adapted_advocate_category, as: :advocate_category
        expose :court, using: API::Entities::CCR::Court
        expose :offence, using: API::Entities::CCR::Offence
        expose :defendants_with_main_first, using: API::Entities::CCR::Defendant, as: :defendants

        expose :additional_information
        expose :bills

        private

        def defendants_with_main_first
          object.defendants.order(created_at: :asc)
        end

        def bills
          data = []
          data.push AdaptedWarrantFee.represent(object.warrant_fee)
          data.push AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end

        def adapted_advocate_category
          ::CCR::AdvocateCategoryAdapter.code_for(object.advocate_category) if object.advocate_category.present?
        end
      end
    end
  end
end

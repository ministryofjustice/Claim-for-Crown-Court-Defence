# This is a work in progress, aiming to provide all
# data possible to enable successful injection
# of a claim into CCR.
#
module API
  module Entities
    class CCLFClaim < BaseEntity
      expose :uuid
      expose :supplier_number
      expose :case_number
      expose  :first_day_of_trial,
              :case_concluded_at,
              :last_submitted_at,
              format_with: :utc

      # adapted case type to bill_scenario for lgfs
      # expose :case_type, using: API::Entities::CCR::CaseType
      expose :court, using: API::Entities::CCR::Court
      expose :offence, using: API::Entities::CCR::Offence
      expose :defendants_with_main_first, using: API::Entities::CCR::Defendant, as: :defendants

      # CCR fees and expenses to bill mappings
      expose :bills

      private

      def defendants_with_main_first
        object.defendants.order(created_at: :asc)
      end

      def bills
        data = []
        # TODO
        # data.push API::Entities::CCLF::AdaptedGraduatedFee.represent(graudated_fees)
        # data.push API::Entities::CCLF::AdaptedFixedFee.represent(fixed_fees)
        # data.push API::Entities::CCLF::AdaptedDisbursments.represent(miscellaneous_fees)
        # data.push API::Entities::CCLF::AdaptedDisbursments.represent(disbursements)
        # data.push API::Entities::CCLF::AdaptedExpense.represent(object.expenses)
        data.flatten.as_json
      end
    end
  end
end

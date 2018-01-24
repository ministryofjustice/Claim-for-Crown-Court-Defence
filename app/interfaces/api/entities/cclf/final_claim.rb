module API
  module Entities
    module CCLF
      class FinalClaim < BaseClaim
        # TODO: WIP - all bills must be addeded
        def bills
          data = []
          data.push API::Entities::CCLF::AdaptedFixedFee.represent(fixed_fees)
          data.push API::Entities::CCLF::AdaptedGraduatedFee.represent(graduated_fees)
          # data.push API::Entities::CCLF::AdaptedMiscFee.represent(miscellaneous_fees)
          # data.push API::Entities::CCLF::AdaptedDisbursments.represent(disbursements)
          # data.push API::Entities::CCLF::AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end

        private

        def fixed_fee_adapter
          ::CCLF::Fee::FixedFeeAdapter.new
        end

        def fixed_fees
          fee = fixed_fee_adapter.call(object)
          [].tap do |arr|
            arr << fee if fee.claimed?
          end
        end

        def graduated_fee_adapter
          ::CCLF::Fee::GraduatedFeeAdapter.new
        end

        def graduated_fees
          fee = graduated_fee_adapter.call(object)
          [].tap do |arr|
            arr << fee if fee.claimed?
          end
        end
      end
    end
  end
end

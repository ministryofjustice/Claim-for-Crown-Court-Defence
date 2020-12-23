module API
  module Entities
    module CCR
      class HardshipClaim < BaseClaim
        expose :case_type, using: API::Entities::CCR::CaseType
        expose :offence, using: API::Entities::CCR::Offence
        expose :first_day_of_trial,
               :trial_fixed_notice_at,
               :trial_fixed_at,
               :trial_cracked_at,
               :retrial_started_at,
               format_with: :utc
        expose :trial_cracked_at_third
        expose :retrial_reduction

        private

        def adapted_hardship_fee
          @adapted_hardship_fee ||= ::CCR::Fee::HardshipFeeAdapter.new(object)
        end

        def hardship_fees
          adapted_hardship_fee.claimed? ? [adapted_hardship_fee] : []
        end

        def bills
          data = []
          data.push AdaptedHardshipFee.represent(hardship_fees)
          data.push AdaptedMiscFee.represent(miscellaneous_fees)
          data.push AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end
      end
    end
  end
end

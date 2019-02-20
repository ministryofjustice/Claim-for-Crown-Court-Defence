module API
  module Entities
    module CCR
      class FinalClaim < BaseClaim
        expose :case_type, using: API::Entities::CCR::CaseType
        expose :offence, using: API::Entities::CCR::Offence
        expose  :first_day_of_trial,
                :trial_fixed_notice_at,
                :trial_fixed_at,
                :trial_cracked_at,
                :retrial_started_at,
                format_with: :utc
        expose :trial_cracked_at_third
        expose :retrial_reduction

        private

        def adapted_basic_fee
          @adapted_basic_fee ||= ::CCR::Fee::BasicFeeAdapter.new(object)
        end

        def basic_fees
          adapted_basic_fee.claimed? ? [adapted_basic_fee] : []
        end

        def adapted_fixed_fee
          @adapted_fixed_fee ||= ::CCR::Fee::FixedFeeAdapter.new.call(object)
        end

        def fixed_fees
          adapted_fixed_fee.claimed? ? [adapted_fixed_fee] : []
        end

        def bills
          data = []
          data.push AdaptedBasicFee.represent(basic_fees)
          data.push AdaptedFixedFee.represent(fixed_fees)
          data.push AdaptedMiscFee.represent(miscellaneous_fees)
          data.push AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end
      end
    end
  end
end

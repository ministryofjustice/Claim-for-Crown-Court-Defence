module API
  module Entities
    module CCR
      class AdaptedHardshipFee < AdaptedBaseFee
        unexpose :case_numbers
        expose :hardship_fee, as: :amount, format_with: :string

        private

        def hardship_fee
          object.filtered_fees.inject(0) do |sum, basic_fee|
            sum + basic_fee.amount
          end
        end
      end
    end
  end
end

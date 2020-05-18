module API
  module Entities
    module CCR
      class AdaptedHardshipFee < AdaptedBaseFee
        unexpose :case_numbers
        with_options(format_with: :string) do
          expose :calculated_fee, using: API::Entities::CCR::CalculatedFee
        end

        private

        def calculated_fee
          AdaptedCalculatedFee.represent(object)
        end
      end
    end
  end
end

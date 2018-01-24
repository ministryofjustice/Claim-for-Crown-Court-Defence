module API
  module Entities
    module CCLF
      class AdaptedFixedFee < AdaptedBaseFee
        expose :bill_scenario
        expose :ppe, format_with: :string

        private

        # TODO: amount from fee??
        def ppe
          # object.amount
        end
      end
    end
  end
end

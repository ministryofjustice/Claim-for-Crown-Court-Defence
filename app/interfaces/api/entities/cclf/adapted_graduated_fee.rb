module API
  module Entities
    module CCLF
      class AdaptedGraduatedFee < AdaptedBaseFee
        expose :bill_scenario
        expose :ppe

        private

        def claim
          # object.object
        end

        # TODO: amount from fee??
        def ppe
          # object.amount
        end
      end
    end
  end
end

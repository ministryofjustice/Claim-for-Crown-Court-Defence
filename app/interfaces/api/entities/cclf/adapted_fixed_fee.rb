module API
  module Entities
    module CCLF
      class AdaptedFixedFee < AdaptedBaseFee
        expose :bill_scenario

        private

        delegate :bill_type, :bill_subtype, :bill_scenario, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::FixedFeeAdapter.new(object)
        end
      end
    end
  end
end

module API
  module Entities
    module CCLF
      class AdaptedFixedFee < AdaptedBaseBill
        expose :quantity, format_with: :integer_string

        private

        delegate :bill_type, :bill_subtype, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::FixedFeeAdapter.new(object)
        end
      end
    end
  end
end

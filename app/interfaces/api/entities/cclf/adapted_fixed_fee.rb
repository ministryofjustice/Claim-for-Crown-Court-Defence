module API
  module Entities
    module CCLF
      class AdaptedFixedFee < AdaptedBaseBill
        expose :amount, format_with: :string

        private

        delegate :bill_type, :bill_subtype, :vat_included, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::FixedFeeAdapter.new(object)
        end
      end
    end
  end
end

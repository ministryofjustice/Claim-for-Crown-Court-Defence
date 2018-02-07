module API
  module Entities
    module CCLF
      class AdaptedMiscFee < AdaptedBaseBill
        expose :amount, format_with: :string
        expose :vat_included

        private

        delegate :bill_type, :bill_subtype, :vat_included, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::MiscFeeAdapter.new(object)
        end
      end
    end
  end
end

module API
  module Entities
    module CCLF
      class AdaptedWarrantFee < AdaptedBaseBill
        expose :warrant_issued_date, :warrant_executed_date, format_with: :utc
        expose :amount, format_with: :string
        expose :vat_included

        private

        delegate :bill_type, :bill_subtype, :vat_included, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::WarrantFeeAdapter.new(object)
        end
      end
    end
  end
end

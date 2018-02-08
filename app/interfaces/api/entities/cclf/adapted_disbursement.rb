module API
  module Entities
    module CCLF
      class AdaptedDisbursement < AdaptedBaseBill
        expose :net_amount, :vat_amount, format_with: :string

        private

        delegate :bill_type, :bill_subtype, to: :adapter

        def adapter
          @adapter ||= ::CCLF::DisbursementAdapter.new(object)
        end
      end
    end
  end
end

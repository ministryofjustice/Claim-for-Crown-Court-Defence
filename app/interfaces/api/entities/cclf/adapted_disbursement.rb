module API
  module Entities
    module CCLF
      class AdaptedDisbursement < AdaptedBaseBill
        # NOTE: CCLF only requires the net amount and calculates vat based on rep order date
        expose :net_amount, format_with: :string
        expose :vat_amount, format_with: :string
        expose :total, format_with: :string

        private

        delegate :bill_type, :bill_subtype, to: :adapter

        def adapter
          @adapter ||= ::CCLF::DisbursementAdapter.new(object)
        end
      end
    end
  end
end

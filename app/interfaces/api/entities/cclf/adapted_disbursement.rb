module API
  module Entities
    module CCLF
      class AdaptedDisbursement < AdaptedBaseBill
        expose :total, format_with: :string

        private

        delegate :bill_type, :bill_subtype, :vat_included, to: :adapter

        def adapter
          @adapter ||= ::CCLF::DisbursementAdapter.new(object)
        end
      end
    end
  end
end

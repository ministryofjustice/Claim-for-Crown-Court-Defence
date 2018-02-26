module API
  module Entities
    module CCLF
      class AdaptedTransferFee < AdaptedBaseBill
        expose :quantity, format_with: :integer_string
        expose :amount, format_with: :string # TODO: check if needed

        private

        delegate :bill_type, :bill_subtype, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::TransferFeeAdapter.new(object)
        end
      end
    end
  end
end

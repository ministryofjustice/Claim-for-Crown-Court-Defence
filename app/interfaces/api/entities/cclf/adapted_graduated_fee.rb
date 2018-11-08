module API
  module Entities
    module CCLF
      class AdaptedGraduatedFee < AdaptedBaseBill
        expose :quantity, format_with: :integer_string

        private

        delegate :bill_type, :bill_subtype, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::GraduatedFeeAdapter.new(object)
        end

        def quantity
          [object.quantity, 1].compact.max
        end
      end
    end
  end
end

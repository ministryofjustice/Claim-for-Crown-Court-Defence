module API
  module Entities
    module CCR
      class AdaptedWarrantFee < AdaptedBaseFee
        unexpose :case_numbers
        expose :warrant_issued_date, format_with: :utc
        expose :amount, format_with: :string

        private

        delegate :bill_type, :bill_subtype, to: :adapter

        def adapter
          @adapter ||= ::CCR::Fee::WarrantFeeAdapter.new(object)
        end
      end
    end
  end
end

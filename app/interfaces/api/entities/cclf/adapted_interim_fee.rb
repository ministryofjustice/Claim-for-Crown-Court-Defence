module API
  module Entities
    module CCLF
      class AdaptedInterimFee < AdaptedBaseBill
        expose :quantity, format_with: :integer_string
        expose :amount, format_with: :string

        expose  :warrant_issued_date,
                :warrant_executed_date,
                format_with: :utc,
                if: ->(instance, _options) { instance.is_interim_warrant? }

        private

        delegate :bill_type, :bill_subtype, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::InterimFeeAdapter.new(object)
        end
      end
    end
  end
end

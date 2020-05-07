module API
  module Entities
    module CCR
      class AdaptedCalculatedFee < API::Entities::BaseEntity
        with_options(format_with: :string) do
          expose :ex_vat
        end

        private

        delegate :ex_vat, :basic_case_fee, :vat, to: :adapter

        def adapter
          @adapter ||= ::CCR::CalculatedFeeAdapter.new(object)
        end
      end
    end
  end
end

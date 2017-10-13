module API
  module Entities
    module CCR
      # expects to receive adapted instances of fees
      # e.g. ::CCR::Fee::MiscFeeAdapter.new.call(fee)
      #
      class AdaptedBaseFee < API::Entities::CCR::BaseEntity
        expose :bill_type
        expose :bill_subtype
        expose :case_numbers
      end
    end
  end
end

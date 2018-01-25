module API
  module Entities
    module CCLF
      class AdaptedBaseFee < API::Entities::BaseEntity
        expose :bill_type
        expose :bill_subtype
        expose :quantity, format_with: :string
        expose :amount, format_with: :string
      end
    end
  end
end

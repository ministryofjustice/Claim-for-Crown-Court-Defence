module API
  module Entities
    module CCR
      class AdaptedBaseFee < API::Entities::BaseEntity
        expose :bill_type
        expose :bill_subtype
        expose :case_numbers
      end
    end
  end
end

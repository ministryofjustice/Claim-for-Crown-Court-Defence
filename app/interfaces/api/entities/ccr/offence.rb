module API
  module Entities
    module CCR
      class Offence < API::Entities::CCR::BaseEntity
        expose :unique_code
        expose :offence_class, using: API::Entities::CCR::OffenceClass
      end
    end
  end
end

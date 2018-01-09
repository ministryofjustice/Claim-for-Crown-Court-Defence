module API
  module Entities
    module CCLF
      class Offence < API::Entities::CCR::BaseEntity
        expose :offence_class, using: API::Entities::CCR::OffenceClass
      end
    end
  end
end

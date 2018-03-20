module API
  module Entities
    module CCR
      class Offence < API::Entities::BaseEntity
        expose :unique_code
        expose :offence_class,
               if: ->(instance, _opts) { instance.fee_schemes.first.number.eql?(9) },
               using: API::Entities::CCR::OffenceClass
      end
    end
  end
end

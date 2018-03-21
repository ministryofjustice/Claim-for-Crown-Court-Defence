module API
  module Entities
    module CCR
      class Offence < API::Entities::BaseEntity
        expose :unique_code
        expose :offence_class,
               if: ->(instance, _opts) { instance.scheme_nine? },
               using: API::Entities::CCR::OffenceClass
      end
    end
  end
end

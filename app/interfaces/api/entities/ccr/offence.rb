module API
  module Entities
    module CCR
      class Offence < API::Entities::BaseEntity
        expose :unique_code_check, as: :unique_code
        expose :offence_class,
               if: ->(instance, _opts) { instance.scheme_nine? },
               using: API::Entities::CCR::OffenceClass

        private

        def unique_code_check
          suffix = object.unique_code.match(/(~\d{2})/)
          return object.unique_code unless suffix.present?
          object.unique_code.sub(suffix[1], '')
        end
      end
    end
  end
end

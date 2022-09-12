module API
  module Entities
    module CCLF
      class Offence < API::Entities::BaseEntity
        expose :unique_code_check, as: :unique_code
        expose :offence_class, using: API::Entities::CCR::OffenceClass

        private

        def unique_code_check
          object.unique_code.split('~').first
        end
      end
    end
  end
end

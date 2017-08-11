module API
  module Entities
    module CCR
      class Offence < API::Entities::CCR::BaseEntity
        expose :faked_legacy_id, as: :id
        expose :offence_class, using: API::Entities::CCR::OffenceClass

        private

        # INJECTION: Using CCR Legacy Offence codes 501-511 for now (which map 1-to-1 onto offence classes)
        # but this will eventually need to provide an ID, UUID or some key that maps
        # CCCD offence records to CCR Offence records.
        def faked_legacy_id
          ('A'..'K').zip(501..511).to_h[object&.offence_class&.class_letter]
        end
      end
    end
  end
end

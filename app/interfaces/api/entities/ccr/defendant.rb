module API
  module Entities
    module CCR
      class Defendant < API::Entities::CCR::BaseEntity
        expose :main_defendant
        expose :representation_orders, using: API::Entities::CCR::RepresentationOrder

        private

        def main_defendant
          object.claim&.defendants&.order(created_at: :asc)&.first == object || false
        end
      end
    end
  end
end

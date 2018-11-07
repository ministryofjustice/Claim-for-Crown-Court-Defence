module API
  module Entities
    module CCR
      class Defendant < API::Entities::BaseEntity
        expose :main_defendant
        expose :first_name
        expose :last_name
        expose :date_of_birth
        expose :earliest_representation_order,
               using: API::Entities::CCR::RepresentationOrder,
               as: :representation_orders

        private

        def main_defendant
          object.claim.defendants.unscope(:order).order(created_at: :asc)&.first == object || false
        end

        def earliest_representation_order
          object.representation_orders.unscope(:order).order(representation_order_date: :asc).take(1)
        end
      end
    end
  end
end

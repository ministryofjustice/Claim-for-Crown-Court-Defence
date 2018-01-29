module API
  module Entities
    module CCR
      class Defendant < API::Entities::BaseEntity
        expose :main_defendant
        expose :first_name
        expose :last_name
        expose :date_of_birth
        expose :representation_orders_with_earliest_first,
               using: API::Entities::CCR::RepresentationOrder,
               as: :representation_orders

        private

        def main_defendant
          object.claim.defendants.unscope(:order).order(created_at: :asc)&.first == object || false
        end

        def representation_orders_with_earliest_first
          object.representation_orders.unscope(:order).order(representation_order_date: :asc)
        end
      end
    end
  end
end

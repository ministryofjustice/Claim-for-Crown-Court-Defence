module API
  module Entities
    module Export
      class RepresentationOrder < API::Entities::Export::BaseEntity
        expose :maat_reference
        expose :representation_order_date, as: :date, format_with: :utc
      end
    end
  end
end

module API
  module Entities
    class RepresentationOrder < BaseEntity
      expose :id
      expose :uuid
      expose :maat_reference
      expose :representation_order_date, as: :date, format_with: :utc
    end
  end
end

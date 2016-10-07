module API
  module Entities
    class RepresentationOrder < UndatedEntity
      expose :id
      expose :uuid
      expose :maat_reference
      expose :representation_order_date, as: :date
    end
  end
end

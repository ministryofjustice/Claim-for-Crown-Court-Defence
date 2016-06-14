module API
  module Entities
    class Offence < UndatedEntity
      expose :id
      expose :description
      expose :offence_class_id
      expose :offence_class, using: API::Entities::OffenceClass, as: :offence_class
    end
  end
end

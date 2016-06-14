module API
  module Entities
    class OffenceClass < UndatedEntity
      expose :id
      expose :class_letter
      expose :description
    end
  end
end

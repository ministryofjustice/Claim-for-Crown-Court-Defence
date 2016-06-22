module API
  module Entities
    class OffenceClass < UndatedEntity
      expose :id
      expose :class_letter
      expose :description
      expose :lgfs_offence_id
    end
  end
end

module API
  module Entities
    class OffenceClass < BaseEntity
      expose :id
      expose :class_letter
      expose :description
      expose :lgfs_offence_id
    end
  end
end

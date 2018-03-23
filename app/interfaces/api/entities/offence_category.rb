module API
  module Entities
    class OffenceCategory < BaseEntity
      expose :id
      expose :number
      expose :description, as: 'name'
    end
  end
end

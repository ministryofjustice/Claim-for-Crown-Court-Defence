module API
  module Entities
    class FeeCategory < BaseEntity
      expose :id
      expose :number
      expose :description, as: 'name'
    end
  end
end

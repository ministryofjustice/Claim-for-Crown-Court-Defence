module API
  module Entities
    class FeeBand < BaseEntity
      expose :id
      expose :description, as: 'name'
      expose :fee_category, using: API::Entities::FeeCategory
    end
  end
end

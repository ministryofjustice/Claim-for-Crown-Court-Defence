module API
  module Entities
    class OffenceBand < BaseEntity
      expose :id
      expose :description, as: 'name'
      expose :offence_category, using: API::Entities::OffenceCategory
    end
  end
end

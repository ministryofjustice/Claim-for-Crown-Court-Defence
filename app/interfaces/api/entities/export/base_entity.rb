module API
  module Entities
    module Export
      class BaseEntity < Grape::Entity
        unexpose :created_at, :updated_at
      end
    end
  end
end

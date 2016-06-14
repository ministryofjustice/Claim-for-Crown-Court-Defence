module API
  module Entities
    class UndatedEntity < Grape::Entity
      unexpose :created_at
      unexpose :updated_at
    end
  end
end

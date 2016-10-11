module API
  module Entities
    class Determination < BaseEntity
      expose :created_at, format_with: :utc

      # TODO maybe? We don't store the creator in the determinations table
      # expose :creator, as: :created_by, using: API::Entities::CaseWorker

      expose :object, as: :totals, using: API::Entities::Totals
    end
  end
end

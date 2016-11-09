module API
  module Entities
    module Export
      class Defendant < API::Entities::Export::User
        expose :representation_orders, using: API::Entities::Export::RepresentationOrder
      end
    end
  end
end

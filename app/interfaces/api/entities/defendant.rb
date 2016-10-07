module API
  module Entities
    class Defendant < API::Entities::User
      expose :representation_orders, using: API::Entities::RepresentationOrder
    end
  end
end

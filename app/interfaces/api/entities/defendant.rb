module API
  module Entities
    class Defendant < API::Entities::User
      expose :date_of_birth
      expose :representation_orders, using: API::Entities::RepresentationOrder
    end
  end
end

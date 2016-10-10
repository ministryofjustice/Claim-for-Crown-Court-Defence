module API
  module Entities
    class User < UndatedEntity
      expose :id
      expose :uuid
      expose :first_name
      expose :last_name
    end
  end
end

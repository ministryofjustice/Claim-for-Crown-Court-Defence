module API
  module Entities
    class Court < UndatedEntity
      expose :id
      expose :code
      expose :name
      expose :court_type
    end
  end
end

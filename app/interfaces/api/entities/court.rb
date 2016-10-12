module API
  module Entities
    class Court < BaseEntity
      expose :id
      expose :code
      expose :name
      expose :court_type
    end
  end
end

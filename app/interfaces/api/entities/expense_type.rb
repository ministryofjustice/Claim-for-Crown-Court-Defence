module API
  module Entities
    class ExpenseType < BaseEntity
      expose :id
      expose :name
      expose :roles
      expose :reason_set
    end
  end
end

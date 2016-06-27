module API
  module Entities
    class ExpenseType < UndatedEntity
      expose :id
      expose :name
      expose :roles
      expose :reason_set
    end
  end
end

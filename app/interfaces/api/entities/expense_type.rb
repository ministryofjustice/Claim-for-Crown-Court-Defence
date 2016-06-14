module API
  module Entities
    class ExpenseType < UndatedEntity
      expose :id
      expose :name
      expose :roles
      expose :reason_set
      expose :expense_reasons, using: API::Entities::ExpenseReason, as: :reasons
    end
  end
end

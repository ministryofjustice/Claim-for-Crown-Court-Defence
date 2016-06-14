module API
  module Entities
    class ExpenseReason < UndatedEntity
      expose :id
      expose :reason
      expose :allow_explanatory_text
    end
  end
end

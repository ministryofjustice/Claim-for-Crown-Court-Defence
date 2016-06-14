module API
  module Entities
    class BaseFeeType < UndatedEntity
      expose :id
      expose :description
      expose :code
      expose :max_amount
      expose :calculated
      expose :roles
      expose :quantity_is_decimal
    end
  end
end

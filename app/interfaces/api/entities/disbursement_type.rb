module API
  module Entities
    class DisbursementType < BaseEntity
      expose :id
      expose :unique_code
      expose :name
    end
  end
end

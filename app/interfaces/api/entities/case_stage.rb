module API
  module Entities
    class CaseStage < BaseEntity
      expose :case_type_id
      expose :unique_code
      expose :description
      expose :roles
    end
  end
end

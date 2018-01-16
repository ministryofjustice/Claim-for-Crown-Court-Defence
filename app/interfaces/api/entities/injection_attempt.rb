module API
  module Entities
    class InjectionAttempt < BaseEntity
      expose :succeeded
      expose :error_messages
      expose :deleted_at
    end
  end
end

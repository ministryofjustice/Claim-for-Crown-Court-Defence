module API
  module Entities
    class InjectionAttempt < BaseEntity
      expose :succeeded
      expose :error_messages
    end
  end
end

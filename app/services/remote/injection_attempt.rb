module Remote
  class InjectionAttempt < Base
    attr_accessor :succeeded, :error_messages

    def failed?
      !succeeded
    end
  end
end

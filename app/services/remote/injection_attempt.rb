module Remote
  class InjectionAttempt < Base
    attr_accessor :succeeded, :error_messages, :deleted_at

    def active?
      deleted_at.nil?
    end
  end
end

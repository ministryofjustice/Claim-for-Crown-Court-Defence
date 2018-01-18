module InjectionAttemptErrorable
  extend ActiveSupport::Concern

  included do
    def last_injection_attempt
      claim.injection_attempts&.last
    end

    def injection_errors
      last_injection_attempt.error_messages if last_injection_attempt&.active?
    end

    def injection_error
      messages = injection_errors
      return unless messages.present?
      message = injection_error_header
      yield(message) if block_given?
      message
    end
    alias_method :injection_error_summary, :injection_error

    def injection_error_hint
      suffix = I18n.t(:form_error_hint, scope: %i[shared injection_errors])
      count = injection_errors.count
      "#{count} #{suffix.pluralize(count)}"
    end

    def injection_error_dismiss_text
      I18n.t(:dismiss, scope: %i[shared injection_errors])
    end

    def injection_error_header
      I18n.t(:error, scope: %i[shared injection_errors])
    end
    private :injection_error_header
  end
end

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
      return if messages.blank?
      message = injection_error_header
      yield(message) if block_given?
      message
    end
    alias_method :injection_error_summary, :injection_error

    def injection_error_hint
      suffix = I18n.t('shared.injection_errors.form_error_hint')
      count = injection_errors.count
      "#{count} #{suffix.pluralize(count)}"
    end

    def injection_error_dismiss_text
      I18n.t('shared.injection_errors.dismiss')
    end

    def injection_error_header
      I18n.t('shared.injection_errors.error')
    end
    private :injection_error_header
  end
end

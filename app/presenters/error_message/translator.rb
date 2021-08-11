#
# This class is reponsible for retrieving plain
# english error messages from a custom location,
# typically error_messages.yml.
#
# It must retrieve english messages based on error keys
# in various formats. These keys come from both custom validations,
# rails validations, including nested attributes style validation
# error messages.
#

module ErrorMessage
  class Translator
    attr_reader :long_message,
                :short_message,
                :api_message,
                :translations

    def initialize(translations)
      @translations = translations
      @long_message = nil
      @short_message = nil
      @api_message = nil
    end

    def message(key, error)
      key = ErrorMessage::Key.new(key)
      error = format_error(error)
      set = translations_for(key)
      message_set = message_set(set, key, error)
      ErrorMessage::Message.new(*message_set, key)
    end

    private

    # Needed for GovUkDateField and Roles error handling (at least)
    # examples:
    # "Invalid date" --> invalid_date
    # "Choose at least one role" --> choose_at_least_one_role
    #
    def format_error(string)
      string.gsub(/\s+/, '_').downcase
    end

    def message_set(set, key, error)
      if translation_exists?(set, key.attribute, error)
        [set[key.attribute][error]['long'],
         set[key.attribute][error]['short'],
         set[key.attribute][error]['api']]
      else
        ErrorMessage::FallbackMessage.new(key, error).all
      end
    end

    def translations_for(key)
      key.submodel? ? translations.fetch(key.model, {}) : translations
    end

    def translation_exists?(set, key, error)
      set.key?(key) && set[key][error].present?
    end
  end
end

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
    include ErrorMessage::Helper

    attr_reader :long_message,
                :short_message,
                :api_message,
                :translations

    def initialize(translations, key = nil, error = nil)
      @translations = translations
      @key = Key.new(key) if key
      @error = format_error(error) if error
      @long_message = nil
      @short_message = nil
      @api_message = nil

      translate! if key && error
    end

    # TODO: dependency inject Key.new from consumers
    # TODO: use instance vars to negate need to pass key, error everywhere
    def message(key, error)
      key = Key.new(key)
      error = format_error(error)
      message_set = message_set(key, error)
      Message.new(*message_set, key)
    end

    private

    def message_set(key, error)
      set = translations_for(key)

      if translation_exists?(set, key.attribute, error)
        [set[key.attribute][error]['long'],
         set[key.attribute][error]['short'],
         set[key.attribute][error]['api']]
      else
        FallbackMessage.new(key, error).all
      end
    end

    def translations_for(key)
      key.submodel? ? translations.fetch(key.model, {}) : translations
    end

    # DEPRECATED
    def translate!
      get_messages(@translations, @key, @error)

      @long_message = substitute_submodel_numbers_and_names(@long_message)
      @short_message = substitute_submodel_numbers_and_names(@short_message)
      @api_message = substitute_submodel_numbers_and_names(@api_message)
    end

    # DEPRECATED
    def get_messages(translations, key, error)
      if key.submodel?
        translation_subset, submodel_key = translation_subset_and_attribute(key)
        get_messages(translation_subset, submodel_key, error)
      elsif translation_exists?(translations, key, error)
        @long_message = translations[key][error]['long']
        @short_message = translations[key][error]['short']
        @api_message = translations[key][error]['api']
      else
        @long_message, @short_message, @api_message = fallback_messages
      end
    end

    # DEPRECATED
    def fallback_messages
      FallbackMessage.new(@key, @error).all
    end

    # DEPRECATED
    def translation_subset_and_attribute(key)
      translation_subset = translations.fetch(key.model, {})
      [translation_subset, key.attribute]
    end

    def translation_exists?(set, key, error)
      set.key?(key) && set[key][error].present?
    end
  end
end

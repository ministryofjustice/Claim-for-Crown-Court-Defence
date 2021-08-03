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
                :translations,
                :translator

    def initialize(translations, key, error)
      @translations = translations
      @key = Key.new(key)
      @error = format_error(error)
      @submodel_numbers = {}
      @long_message = nil
      @short_message = nil
      @api_message = nil

      translate!
    end

    def translation_found?
      !translation_not_found?
    end

    def translation_not_found?
      @long_message.nil? || @short_message.nil? || @api_message.nil?
    end

    private

    def translate!
      get_messages(@translations, @key, @error)

      return unless translation_found?
      @long_message = substitute_submodel_numbers_and_names(@long_message)
      @short_message = substitute_submodel_numbers_and_names(@short_message)
      @api_message = substitute_submodel_numbers_and_names(@api_message)
    end

    def get_messages(translations, key, error)
      if key.submodel?
        translation_subset, submodel_key = extract_submodel_attribute(key)
        get_messages(translation_subset, submodel_key, error)
      elsif translation_exists?(translations, key, error)
        @long_message = translations[key][error]['long']
        @short_message = translations[key][error]['short']
        @api_message = translations[key][error]['api']
      end
    end

    def extract_submodel_attribute(key)
      @submodel_numbers = key.all_model_indices
      translation_subset = translations.fetch(key.model, {})
      [translation_subset, key.attribute]
    end

    def substitute_submodel_numbers_and_names(message)
      @submodel_numbers.each do |submodel_name, number|
        int = number.to_i
        int += 1 if zero_based?(@key)
        substitution_key = '#{' + submodel_name + '}'
        substitution_value = [to_ordinal(int), humanize_model_name(submodel_name)].select(&:present?).join(' ')
        message = message.sub(substitution_key, substitution_value)
      end

      # clean out unused message substitution keys
      message.gsub(/#\{(\S+)\}/, '')
    end

    def translation_exists?(translations, key, error)
      translations.key?(key) && translations[key][error].present?
    end
  end
end

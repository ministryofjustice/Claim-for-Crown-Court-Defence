module ErrorMessage
  class Presenter
    attr_reader :error_details

    def initialize(object, message_file = nil)
      @errors = object.errors
      message_file ||= default_file
      @translations = YAML.load_file(message_file)
      @error_details = DetailCollection.new
      generate_messages
    end

    delegate :errors_for?,
             :header_errors,
             :size,
             :short_messages_for,
             :long_messages_for,
             :api_messages_for,
             to: :error_details

    alias key? errors_for?
    alias field_errors_for short_messages_for
    alias summary_error_for long_messages_for

    private

    def generate_messages
      @errors.each do |error|
        attribute = error.attribute
        message = translator.message(error.attribute, error.message)
        next if @error_details[attribute] && @error_details[attribute][0].long_message.eql?(message.long)
        add_error_detail(attribute, message)
      end
    end

    def add_error_detail(attribute, message)
      @error_details[attribute] = Detail.new(
        attribute,
        message.long,
        message.short,
        message.api,
        generate_sequence(attribute)
      )
    end

    def translator
      @translator ||= ErrorMessage::Translator.new(@translations)
    end

    def translations_subset_and_parent_sequence(key)
      key = ErrorMessage::Key.new(key)

      if key.numbered_submodel?
        parent_sequence = @translations.dig(key.model, '_seq')
        translations_subset = @translations.dig(key.model, key.attribute)
      else
        translations_subset = @translations[key]
      end
      parent_sequence ||= 0

      [translations_subset, parent_sequence]
    end

    # NOTE: sequence = (attribute's _seq value + parent's _seq value) or parents _seq or 99999
    #
    def generate_sequence(key)
      translations_subset, parent_sequence = translations_subset_and_parent_sequence(key)
      begin
        translations_subset['_seq'].present? ? translations_subset['_seq'] + parent_sequence : parent_sequence || 99_999
      rescue StandardError
        99_999
      end
    end

    def default_file
      ErrorMessage.default_translation_file
    end
  end
end

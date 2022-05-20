module ErrorMessage
  class Presenter
    attr_reader :error_detail_collection

    def initialize(object, message_file = nil)
      @errors = object.errors
      message_file ||= default_file
      @translations = YAML.load_file(message_file, aliases: true)
      @error_detail_collection = DetailCollection.new
      generate_messages
    end

    delegate :errors_for?,
             :summary_errors,
             :size,
             :short_messages_for,
             :formatted_error_messages,
             to: :error_detail_collection

    alias key? errors_for?
    alias field_errors_for short_messages_for

    private

    def generate_messages
      @errors.each do |error|
        attribute = error.attribute
        message = translator.message(error.attribute, error.message)

        next if error_detail_item?(attribute, message)
        add_error_detail(attribute, message)
      end
    end

    def error_detail_item?(attribute, message)
      @error_detail_collection[attribute] &&
        @error_detail_collection[attribute][0].long_message.eql?(message.long)
    end

    def add_error_detail(attribute, message)
      @error_detail_collection[attribute] = Detail.new(
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

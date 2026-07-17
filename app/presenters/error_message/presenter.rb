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
        next if error_detail_item?(attribute, message) || error_is_for_govuk_has_one_association?(attribute)
        add_error_detail(attribute, message)
      end
    end

    def error_is_for_govuk_has_one_association?(attribute)
      govuk_has_one_associations.any? { |association| attribute.to_s.include?(association) }
    end

    def govuk_has_one_associations
      @govuk_has_one_associations ||= %w[fixed_fee. graduated_fee. interim_fee. transfer_fee. warrant_fee.] # add associations to the array as they are migrated - eg %w[graduated_fee. fixed_fee.]
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
        sequencer.generate(attribute)
      )
    end

    def translator
      @translator ||= ErrorMessage::Translator.new(@translations)
    end

    def sequencer
      @sequencer ||= ErrorMessage::Sequencer.new(translations: @translations)
    end

    def default_file
      ErrorMessage.default_translation_file
    end
  end
end

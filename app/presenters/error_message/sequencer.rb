module ErrorMessage
  class Sequencer
    def initialize(translations:)
      @translations = translations
    end

    def generate(key)
      # NOTE: sequence = (attribute's _seq value + parent's _seq value) or parents _seq or 99999
      #
      translations_subset, parent_sequence = translations_subset_and_parent_sequence(key)
      begin
        translations_subset['_seq'].present? ? translations_subset['_seq'] + parent_sequence : parent_sequence || 99_999
      rescue StandardError
        99_999
      end
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
  end
end

require 'terminal-table'

module RakeHelpers
  class CanaryChecker
    TYPES = {
      documents: {
        klass: Document,
        columns: {
          'Id' => ->(doc) { doc.id },
          'Document filename' => ->(doc) { doc.document.filename },
          'Preview filename' => ->(doc) { doc.converted_preview_document.filename }
        }
      },
      messages: {
        klass: Message,
        columns: {
          'Id' => ->(doc) { doc.id },
          'Message text' => ->(doc) { doc.body },
          'Attachment filename' => ->(doc) { doc.attachment.filename }
        }
      },
    }

    def initialize(type)
      @type = type.to_sym
    end

    def display
      if TYPES[@type].nil?
        puts "Unknown type '#{@type}'."
        puts "Available types; #{TYPES.keys.join(', ')}"
      else
        puts Terminal::Table.new(
          style: { border: :unicode_round },
          headings: TYPES[@type][:columns].keys,
          rows: TYPES[@type][:klass].where(claim: nil).map do |item|
            TYPES[@type][:columns].values.map { |value| value.call(item) }
          end
        )
      end
    end
  end
end

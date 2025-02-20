# This class holds a collection of ErrorMessage::Detail objects, keyed by fieldname to which error it pertains.
# Each key can hold more than one ErrorMessage::Detail.  The class provides specialised methods for retrieving
# short messages by fieldname, and all the long messages with associated fieldnames
#
module ErrorMessage
  class DetailCollection
    delegate :[], to: :@detail_collection

    def initialize
      @detail_collection = {}
    end

    def []=(fieldname, error_detail)
      if @detail_collection.key?(fieldname)
        @detail_collection[fieldname] << error_detail
      else
        @detail_collection[fieldname] = [error_detail]
      end
    end

    def errors_for?(fieldname)
      @detail_collection.key?(fieldname)
    end

    def short_messages_for(fieldname)
      messages_for(fieldname, :short_message)
    end

    # Called by govuk-formbuilder to generate summary errors
    # when a presenter instance is injected in to govuk_error_summary.
    # See https://govuk-form-builder.netlify.app/introduction/error-handling/#custom-summary-error-presenter-injection
    #
    def formatted_error_messages
      summary_errors.map(&:to_summary_error)
    end

    def summary_errors
      summary_errors = []
      @detail_collection.each_value do |detail_array|
        detail_array.each do |detail|
          summary_errors << detail
        end
      end
      summary_errors.sort!
    end

    def size
      @detail_collection.values.sum(&:size)
    end

    private

    def messages_for(fieldname, message_version)
      error_detail_array = @detail_collection[fieldname]
      return '' if error_detail_array.nil?
      error_detail_array.map { |detail| detail.send(message_version) }.join(', ')
    end
  end
end

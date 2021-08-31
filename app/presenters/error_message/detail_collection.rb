# This class holds a collection of ErrorMessage::Detail objects, keyed by fieldname to which error it pertains.
# Each key can hold more than one ErrorMessage::Detail.  The class provides specialised methods for retrieving
# short messages by fieldname, and all the long messages with associated fieldnames
#
module ErrorMessage
  class DetailCollection
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

    def [](fieldname)
      @detail_collection[fieldname]
    end

    def short_messages_for(fieldname)
      messages_for(fieldname, :short_message)
    end

    # This method is called by govuk-formbuilder to generate summary errors
    # when a presenter instance is injected in to govuk_error_summary.
    #
    def formatted_error_messages
      header_errors.map { |detail| [detail.attribute, detail.long_message] }
    end

    def header_errors
      header_errors = []
      @detail_collection.each_value do |detail_array|
        detail_array.each do |detail|
          header_errors << detail
        end
      end
      header_errors.sort!
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

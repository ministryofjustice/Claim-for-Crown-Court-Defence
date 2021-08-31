# This class holds a collection of ErrorMessage::Detail objects, keyed by fieldname to which error it pertains.
# Each key can hold more than one ErrorMessage::Detail.  The class provides specialised methods for retrieving
# short messages by fieldname, and all the long messages with associated fieldnames
#
module ErrorMessage
  class DetailCollection
    def initialize
      @error_details = {}
    end

    def []=(fieldname, error_detail)
      if @error_details.key?(fieldname)
        @error_details[fieldname] << error_detail
      else
        @error_details[fieldname] = [error_detail]
      end
    end

    def errors_for?(fieldname)
      @error_details.key?(fieldname)
    end

    def [](fieldname)
      @error_details[fieldname]
    end

    def short_messages_for(fieldname)
      messages_for(fieldname, :short_message)
    end

    def long_messages_for(fieldname)
      messages_for(fieldname, :long_message)
    end

    def api_messages_for(fieldname)
      messages_for(fieldname, :api_message)
    end

    def header_errors
      result_array = []
      @error_details.each_value do |value_array|
        value_array.each do |error_detail|
          result_array << error_detail
        end
      end
      result_array.sort!
    end

    def size
      @error_details.values.sum(&:size)
    end

    private

    def messages_for(fieldname, message_version)
      error_detail_array = @error_details[fieldname]
      return '' if error_detail_array.nil?
      error_detail_array.map { |detail| detail.send(message_version) }.join(', ')
    end
  end
end

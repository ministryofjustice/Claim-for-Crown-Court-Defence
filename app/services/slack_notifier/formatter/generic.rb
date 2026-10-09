class SlackNotifier
  class Formatter
    class Generic < Formatter
      attr_reader :status

      def attachment(title: nil, message: nil, status: :pass)
        @status = status

        {
          fallback: message,
          color: message_colour,
          title:,
          text: message
        }.compact
      end
    end
  end
end

class SlackNotifier
  class Formatter
    class Generic < Formatter
      attr_reader :message_icon, :status

      def build(icon:, title:, message:, status:)
        @message_icon = icon
        @status = status

        {
          fallback: message,
          color: message_colour,
          title: title,
          text: message
        }
      end
    end
  end
end

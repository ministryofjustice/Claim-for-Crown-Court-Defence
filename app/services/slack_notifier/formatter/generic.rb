class SlackNotifier
  class Formatter
    class Generic < Formatter
      attr_reader :message_icon

      def build(icon:, title:, message:, pass_fail:)
        @message_icon = icon

        {
          fallback: message,
          color: pass_fail_colour(pass_fail),
          title: title,
          text: message
        }
      end
    end
  end
end

class SlackNotifier
  class Formatter
    class Generic < Formatter
      private

      def message_icon
        @data[:icon]
      end

      def message_fallback
        @data[:message]
      end

      def status
        @data[:status]
      end

      def message_title
        @data[:title]
      end

      def message_text
        @data[:message]
      end
    end
  end
end

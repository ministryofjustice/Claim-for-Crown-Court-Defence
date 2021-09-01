class SlackNotifier
  class Formatter
    class Transitioner < Formatter
      ICONS = {
        nil => ':sign-roadworks:',
        pass: ':smile_cat:',
        fail: ':scream_cat:'
      }.freeze

      attr_reader :status

      def attachment(processed:, failed:)
        @status = failed.zero? ? :pass : :fail

        {
          fallback: message_text(processed, failed),
          color: message_colour,
          title: message_title(failed),
          text: message_text(processed, failed)
        }.compact
      end

      def message_icon
        ICONS[@status]
      end

      private

      def message_title(failed)
        return 'Stale claim archiver completed' if failed.zero?

        'Stale claim archiver completed with failures'
      end

      def message_text(processed, failed)
        "#{processed} transitions processed (#{failed} failed)"
      end
    end
  end
end

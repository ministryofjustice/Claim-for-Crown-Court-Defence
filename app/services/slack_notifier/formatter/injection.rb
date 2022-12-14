class SlackNotifier
  class Formatter
    class Injection < Formatter
      def attachment(uuid:, from: 'indeterminable system', errors: [], **_args)
        @errors = errors
        @claim = Claim::BaseClaim.find_by(uuid:)

        @message_icon = injected? ? Settings.slack.success_icon : Settings.slack.fail_icon
        {
          fallback: "#{generate_message} {#{uuid}}",
          color: message_colour,
          title: "Injection into #{from} #{injected? ? 'succeeded' : 'failed'}",
          text: uuid,
          fields: fields(errors:)
        }
      end

      private

      def generate_message
        if @claim.nil?
          'Failed to inject because no claim found'
        elsif injected?
          "Claim #{@claim.case_number} successfully injected"
        else
          "Claim #{@claim.case_number} could not be injected"
        end
      end

      def status
        injected? ? :pass : :fail
      end

      def fields(errors: [])
        [
          { title: 'Claim number', value: @claim&.case_number, short: true },
          { title: 'environment', value: ENV.fetch('ENV', nil), short: true }
        ] + error_fields(errors)
      end

      def error_fields(errors)
        return [] if errors.empty?

        [{ title: 'Errors', value: errors.pluck('error').join('\n') }]
      end

      def injected?
        @errors.empty? && @claim.present?
      end
    end
  end
end

class SlackNotifier
  class Formatter
    class Injection < Formatter
      def build(response)
        @response = response
        @claim = Claim::BaseClaim.find_by(uuid: @response[:uuid])

        {
          fallback: injection_fallback,
          color: message_colour,
          title: injection_title,
          text: @response[:uuid],
          fields: fields
        }
      end

      def message_icon
        injected? ? Settings.slack.success_icon : Settings.slack.fail_icon
      end

      private

      def injection_fallback
        "#{generate_message} {#{@response[:uuid]}}"
      end

      def generate_message
        if @claim.nil?
          'Failed to inject because no claim found'
        elsif injected?
          "Claim #{@claim.case_number} successfully injected"
        else
          "Claim #{@claim.case_number} could not be injected"
        end
      end

      def message_colour
        pass_fail_colour(injected?)
      end

      def injection_title
        "Injection into #{app_name} #{injected? ? 'succeeded' : 'failed'}"
      end

      def app_name
        @response[:from] || 'indeterminable system'
      end

      def fields
        fields = [
          { title: 'Claim number', value: @claim&.case_number, short: true },
          { title: 'environment', value: ENV['ENV'], short: true }
        ]
        errors = no_errors? ? [] : error_fields
        fields + errors
      end

      def error_fields
        errors = @response[:errors].map { |x| x['error'] }.join('\n')
        [
          { title: 'Errors', value: errors }
        ]
      end

      def injected?
        no_errors? && @claim.present?
      end

      def no_errors?
        @response[:errors].empty?
      end
    end
  end
end

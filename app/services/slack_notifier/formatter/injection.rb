class SlackNotifier
  class Formatter
    class Injection < Formatter
      def build(response)
        @response = response.stringify_keys
        @claim = Claim::BaseClaim.find_by(uuid: @response['uuid'])

        @payload = {
          channel: @channel,
          username: @username,  
          icon_emoji: message_icon,
          attachments: [
            {
              fallback: injection_fallback,
              color: message_colour,
              title: injection_title,
              text: @response['uuid'],
              fields: fields
            }
          ]
        }
        @ready_to_send = true
      rescue StandardError
        @ready_to_send = false
      end

      private

      def message_icon
        injected? ? Settings.slack.success_icon : Settings.slack.fail_icon
      end

      def injection_fallback
        "#{generate_message} {#{@response['uuid']}}"
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
        @response['from'] || 'indeterminable system'
      end

      def fields
        fields = [
          { title: 'Claim number', value: @claim&.case_number, short: true },
          { title: 'environment', value: ENV['ENV'], short: true }
        ]
        errors = has_no_errors? ? [] : error_fields
        fields + errors
      end

      def error_fields
        errors = @response['errors'].map { |x| x['error'] }.join('\n')
        [{ title: 'Errors', value: errors }]
      end

      def injected?
        has_no_errors? && @claim.present?
      end

      def has_no_errors?
        @response['errors'].empty?
      end
    end
  end
end
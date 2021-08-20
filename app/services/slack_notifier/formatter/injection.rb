class SlackNotifier
  class Formatter
    class Injection < Formatter
      private

      def prebuild(**data)
        @response = data.stringify_keys
        @claim = Claim::BaseClaim.find_by(uuid: @response['uuid'])
      end

      def attachment
        {
          fallback: message_fallback,
          color: message_colour,
          title: message_title,
          text: @response['uuid'],
          fields: fields
        }
      end

      def message_icon
        injected? ? Settings.slack.success_icon : Settings.slack.fail_icon
      end

      def message_fallback
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

      def status
        injected? ? :pass : :fail
      end

      def message_title
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
        errors = no_errors? ? [] : error_fields
        fields + errors
      end

      def error_fields
        errors = @response['errors'].map { |x| x['error'] }.join('\n')
        [{ title: 'Errors', value: errors }]
      end

      def injected?
        no_errors? && @claim.present?
      end

      def no_errors?
        @response['errors'].empty?
      end
    end
  end
end

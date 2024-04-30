module API
  module Helpers
    module ErrorLoggingHelper
      def log_error(status, error)
        LogStuff.send(
          :error,
          type: 'api-error',
          request_id: env['action_dispatch.request_id'],
          error: error ? "#{error.class} - #{error.message}" : 'false',
          status:
        ) do
          "API request failed with code #{status}"
        end
      end
    end
  end
end

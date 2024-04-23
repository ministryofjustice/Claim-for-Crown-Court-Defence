module API
  module Helpers
    module ErrorLoggingHelper
      def log_error(status, error)
        LogStuff.send(
          :error,
          type: 'api-error',
          error: error ? "#{error.class} - #{error.message}" : 'false'
        ) do
          "API request failed with code #{status}"
        end
      end
    end
  end
end

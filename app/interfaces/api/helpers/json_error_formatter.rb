module API::Helpers
  module JsonErrorFormatter
    class << self
      # NOTE: latest version of grape requires an extra argument (original_exception)
      def call(messages, _backtrace, _options = {}, _env = nil, _original_exception)
        wrap_messages(*messages).to_json
      end

      private

      def wrap_messages(*messages)
        messages.map { |msg| { error: msg.strip } }
      end
    end
  end
end

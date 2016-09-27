module API::Helpers
  module JsonErrorFormatter

    class << self
      def call(messages, _backtrace, _options = {}, _env = nil)
        wrap_messages(*messages).to_json
      end

      private

      def wrap_messages(*messages)
        messages.map { |msg| {error: msg.strip} }
      end
    end

  end
end

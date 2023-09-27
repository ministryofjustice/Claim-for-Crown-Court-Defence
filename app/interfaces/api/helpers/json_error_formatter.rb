module API
  module Helpers
    module JsonErrorFormatter
      class << self
        # NOTE: latest version of grape requires an extra argument (original_exception)
        def call(messages, _backtrace, _original_exception, _options = {}, _env = nil)
          wrap_messages(*messages).to_json
        end

        private

        def wrap_messages(*messages)
          messages.map { |msg| { error: msg.strip } }
        end
      end
    end
  end
end

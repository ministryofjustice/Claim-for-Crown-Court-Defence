module API
  module Helpers
    module JsonErrorFormatter
      class << self
        def call(error:, **)
          wrap_messages(*Array(error.message)).to_json
        end

        private

        def wrap_messages(*messages)
          messages.map { |msg| { error: msg.strip } }
        end
      end
    end
  end
end
